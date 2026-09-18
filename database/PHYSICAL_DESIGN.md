# OISM — Thiết kế Vật lý (Physical Design) trên SQL Server

Tài liệu này trình bày các quyết định thiết kế vật lý áp dụng cho
`schema.sql` v2.0, đối chiếu với checklist Physical Design đã yêu cầu.

---

## 1. PK / FK / CHECK / UNIQUE — tổng hợp

Chi tiết từng bảng xem trực tiếp trong `schema.sql` (đã có comment giải
thích tại mỗi chỗ sửa). Tóm tắt số lượng ràng buộc theo loại:

| Loại ràng buộc | Số lượng | Mục đích chính |
|---|---|---|
| PRIMARY KEY | 20 (1 bảng — `stock_balances` — dùng khóa phức hợp tự nhiên, 19 bảng dùng UNIQUEIDENTIFIER surrogate) | Định danh duy nhất mỗi dòng |
| FOREIGN KEY | 45 cột khóa ngoại / 44 cặp bảng cha-con | Toàn vẹn tham chiếu, đảm bảo lossless-join (xem LOGICAL_DESIGN.md mục 6) |
| CHECK | 27 | Ép buộc miền giá trị hợp lệ (status enum, số lượng > 0, available ≥ 0...) |
| UNIQUE | 13 | Hiện thực hóa các candidate key phụ đã liệt kê ở LOGICAL_DESIGN.md mục 5 |
| Computed column (PERSISTED) | 3 | Loại bỏ dữ liệu dư thừa (`subtotal`, `variance_qty`, `available`) |

*(Số liệu trên được kiểm đếm lại bằng script phân tích trực tiếp `schema.sql`,
không phải ước lượng thủ công — đảm bảo khớp 100% với file thật.)*

**Bổ sung sau rà soát:** phát hiện thiếu ràng buộc "1 chi nhánh chỉ được có
tối đa 1 phiên kiểm kho đang `InProgress` tại một thời điểm" — nếu không có,
2 nhân viên có thể vô tình tạo 2 phiên kiểm kho trùng nhau trên cùng chi
nhánh. Đã bổ sung bằng **Filtered Unique Index** (tính năng riêng của SQL
Server, cho phép UNIQUE chỉ áp dụng cho tập con dòng thỏa điều kiện `WHERE`):
```sql
CREATE UNIQUE NONCLUSTERED INDEX uq_stocktake_one_active_per_branch
    ON stocktakes (branch_id)
    WHERE status = 'InProgress';
```
Đây là giải pháp thanh lịch hơn so với `UNIQUE(branch_id, status)` thông
thường — vì cách đó sẽ chặn nhầm cả trường hợp hợp lệ "2 phiên kiểm kho đã
`Completed` trong quá khứ trên cùng chi nhánh".

---

## 2. Tenant Isolation — 2 lớp phòng thủ

**Lớp 1 (đã có trong schema.sql):** cột `tenant_id` trên mọi bảng nghiệp vụ
(xem LOGICAL_DESIGN.md mục 4.1), làm cơ sở cho EF Core Global Query Filter ở
tầng Backend (ngoài phạm vi đồ án hiện tại).

**Lớp 2 (khuyến nghị bổ sung — Row-Level Security của SQL Server):**
SQL Server hỗ trợ native Row-Level Security (RLS), cho phép ép buộc cô lập
Tenant **ngay tại tầng CSDL**, độc lập với việc tầng ứng dụng có viết đúng
`WHERE tenant_id = ...` hay không — đây là lớp phòng thủ sau cùng nếu
Backend có lỗi quên filter:

```sql
CREATE FUNCTION dbo.fn_tenant_predicate(@tenant_id UNIQUEIDENTIFIER)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS result
WHERE @tenant_id = CAST(SESSION_CONTEXT(N'TenantId') AS UNIQUEIDENTIFIER);

CREATE SECURITY POLICY TenantIsolationPolicy
ADD FILTER PREDICATE dbo.fn_tenant_predicate(tenant_id) ON dbo.orders,
ADD FILTER PREDICATE dbo.fn_tenant_predicate(tenant_id) ON dbo.inventory_transactions,
ADD FILTER PREDICATE dbo.fn_tenant_predicate(tenant_id) ON dbo.stock_balances
-- ... lặp lại cho các bảng nghiệp vụ còn lại
WITH (STATE = ON);
```
Backend đặt `SESSION_CONTEXT('TenantId', @tenant_id)` ngay sau khi xác thực
JWT ở đầu mỗi connection/request. **Chưa đưa vào `schema.sql` v2.0** vì cần
Backend thật để set SESSION_CONTEXT mới phát huy tác dụng (nằm ngoài phạm vi
bàn giao hiện tại) — ghi nhận là hạng mục triển khai ưu tiên cao ở học kỳ
lập trình Backend.

---

## 3. Inventory Reservation (chống bán vượt tồn)

Đã hiện thực ở mức thiết kế trong Chương 4 báo cáo — tóm tắt lại nguyên tắc
áp dụng cho schema v2.0:

```sql
BEGIN TRANSACTION;
SELECT on_hand, reserved
FROM stock_balances WITH (UPDLOCK, ROWLOCK)
WHERE branch_id = @branch_id AND sku_id = @sku_id;   -- PK tự nhiên, khóa trực tiếp

-- Kiểm tra (on_hand - reserved) >= @requested_qty ở tầng ứng dụng
UPDATE stock_balances
SET reserved = reserved + @requested_qty, updated_at = SYSDATETIMEOFFSET()
WHERE branch_id = @branch_id AND sku_id = @sku_id;
COMMIT TRANSACTION;
```
**Khác biệt so với v1.0:** vì `stock_balances` v2.0 dùng PK tự nhiên
`(branch_id, sku_id)` thay vì surrogate `balance_id`, câu lệnh khóa hàng có
thể `WHERE` trực tiếp trên PK — SQL Server tận dụng được Clustered Index
Seek thay vì phải seek qua Nonclustered Index rồi lookup, giảm 1 bước I/O so
với thiết kế cũ.

Ràng buộc `CHECK (on_hand - reserved >= 0)` đóng vai trò lưới an toàn cuối
cùng ở tầng CSDL — kể cả nếu logic ứng dụng có lỗi, SQL Server vẫn từ chối
mọi UPDATE khiến tồn kho khả dụng âm.

---

## 4. WAC (Weighted Average Cost) / Order Cost Snapshot

- `stock_balances.avg_cost`: cập nhật theo công thức bình quân gia quyền mỗi
  khi `purchase_receipts` chuyển sang `Confirmed`, trong cùng transaction với
  việc ghi `inventory_transactions` (đảm bảo atomic — NFR-SEC-02).
- `order_items.cost_price`: snapshot `avg_cost` tại thời điểm `orders`
  chuyển `Confirmed`, **NOT NULL** (bắt buộc phải có giá trị, không cho phép
  bán hàng mà không xác định được giá vốn) — khác với `unit_price` vốn có
  thể lấy trực tiếp từ `sku_variants.price`.

---

## 5. Inventory Append-only Ledger

Xem `ledger_constraints.sql` (không đổi so với bản TV1 đã viết — kỹ thuật
`INSTEAD OF UPDATE, DELETE` đã đúng). Bổ sung khuyến nghị nhỏ: nên thêm
`SET XACT_ABORT ON` ở đầu trigger để đảm bảo `ROLLBACK TRANSACTION` bên
trong luôn hủy toàn bộ batch một cách nhất quán, tránh trường hợp câu lệnh
sau đó trong cùng batch vẫn chạy tiếp trên một transaction đã bị rollback:

```sql
ALTER TRIGGER trg_Prevent_Update_Delete_Inventory
ON inventory_transactions
INSTEAD OF UPDATE, DELETE
AS
BEGIN
    SET XACT_ABORT ON;
    RAISERROR ('Lỗi bảo mật: Không được phép UPDATE hoặc DELETE trên sổ cái kho...', 16, 1);
    ROLLBACK TRANSACTION;
END;
```

---

## 6. Index theo Workload (OLTP)

Nguyên tắc thiết kế: phân tích **mẫu truy vấn thực tế** thay vì đánh index
tràn lan (mỗi index thừa đều làm chậm INSERT/UPDATE trên bảng ghi nhiều như
`inventory_transactions`, `orders`).

| Truy vấn điển hình | Tần suất | Index phục vụ |
|---|---|---|
| Khóa + đọc tồn kho 1 SKU/branch khi Reserve/Checkout | Rất cao (mỗi giao dịch bán) | PK tự nhiên `(branch_id, sku_id)` — không cần thêm index |
| Tra cứu SKU theo barcode tại POS | Rất cao | `UNIQUE(code)` trên `barcodes` |
| Ghi 1 dòng Ledger mỗi giao dịch | Rất cao (write) | Không đánh thêm index ngoài PK — ưu tiên tốc độ ghi |
| Báo cáo doanh thu lọc theo Tenant + khoảng thời gian | Trung bình (đọc, theo lịch) | `idx_ledger_tenant_created`, `idx_orders_tenant_created` |
| Báo cáo lọc theo Tenant + SKU | Trung bình | `idx_ledger_tenant_sku`, `idx_order_items_tenant_sku` |
| Job tự hủy đơn Reserved quá hạn (quét định kỳ) | Thấp (background) | `idx_orders_tenant_status` (INCLUDE created_at để tránh key lookup) |
| Cảnh báo tồn kho thấp | Thấp (định kỳ) | `idx_stock_tenant_available` trên computed column `available` |
| Đăng nhập theo email | Trung bình | `idx_users_tenant_email` |

**Nguyên tắc không đánh thừa index:** không tạo index trên
`purchase_receipt_items`, `stock_transfer_items`, `stocktake_items` ngoài
UNIQUE constraint bắt buộc — đây là các bảng chi tiết, khối lượng ghi thấp,
truy vấn luôn đi qua bảng cha trước (receipt_id/transfer_id/stocktake_id đã
là FK có index tự động từ PK phía bảng cha).

---

## 7. Đánh giá OLTP (Online Transaction Processing)

**Đặc điểm workload của OISM:**
- Giao dịch ngắn, tần suất cao: Reserve/Confirm/Deduct, mỗi giao dịch chỉ
  đụng tới 1-3 bảng, hoàn tất trong vài chục milliseconds (NFR-PERF-01).
  → Schema chuẩn hóa 3NF/BCNF (mục Logical Design) là lựa chọn đúng cho OLTP:
  ưu tiên tính nhất quán ghi (write consistency) hơn tốc độ đọc tổng hợp —
  ngược lại hoàn toàn với mô hình OLAP/star-schema (vốn cố ý phi chuẩn hóa để
  tối ưu đọc).
- **Tranh chấp tài nguyên (lock contention):** điểm nóng nhất là bảng
  `stock_balances` — nhiều giao dịch có thể cùng chờ khóa trên 1 dòng
  (kịch bản Flash Sale, NFR-PERF-02). Đã xử lý bằng `WITH (UPDLOCK, ROWLOCK)`
  ở mức dòng, tránh SQL Server tự động leo thang (escalate) lên khóa
  trang/bảng làm giảm concurrency toàn hệ thống.
- **Đọc báo cáo chặn ghi OLTP (reader-writer blocking):** mặc định SQL
  Server dùng `READ COMMITTED` — một truy vấn báo cáo (`SELECT` dài) có thể
  bị chặn bởi giao dịch ghi đang mở, và ngược lại. **Khuyến nghị:** bật
  `READ_COMMITTED_SNAPSHOT` ở mức database để các truy vấn đọc (Dashboard,
  Reporting) dùng row-versioning thay vì xin khóa, không chặn luồng OLTP ghi:
  ```sql
  ALTER DATABASE OISM SET READ_COMMITTED_SNAPSHOT ON;
  ```
  Đánh đổi: tăng nhẹ dung lượng tempdb (lưu version cũ của dòng dữ liệu) —
  chấp nhận được vì đổi lấy giảm blocking đáng kể giữa OLTP và Reporting.
- **Kết luận đánh giá:** schema hiện tại phù hợp cho OLTP ở quy mô khởi
  điểm/early-stage SaaS. Khi hệ thống có nhiều Tenant lớn đồng thời, nên tách
  Reporting (FR-REP) sang read-replica hoặc data warehouse riêng thay vì
  chạy trực tiếp trên OLTP database — nằm ngoài phạm vi đồ án hiện tại,
  ghi nhận là hướng mở rộng.

---

## 8. Chiến lược Backup / Recovery

| Hạng mục | Khuyến nghị |
|---|---|
| Recovery model | **FULL** (bắt buộc — dữ liệu Ledger tài chính không được phép mất giao dịch, cần point-in-time recovery) |
| Full backup | Hàng tuần (hoặc hàng ngày trong giai đoạn phát triển) |
| Differential backup | Hàng ngày |
| Transaction log backup | Mỗi 15 phút (bảng `inventory_transactions`/`orders` ghi liên tục — log backup thưa sẽ khiến file log phình to và tăng rủi ro mất dữ liệu) |
| RPO (Recovery Point Objective) | ≤ 15 phút, khớp chu kỳ log backup |
| RTO (Recovery Time Objective) | ≤ 1 giờ cho môi trường học kỳ; production thật nên < 15 phút |
| Retention | Tối thiểu 30 ngày cho full/differential, 7 ngày cho transaction log |
| Kiểm thử phục hồi | Diễn tập restore định kỳ (hàng quý) lên môi trường tách biệt để xác nhận backup thực sự dùng được, không chỉ "chạy xong không lỗi" |
| Vị trí lưu trữ | Tách biệt vật lý với server chính (khác ổ đĩa/khác vùng lưu trữ), tối thiểu theo nguyên tắc 3-2-1 |

*(Đây là khuyến nghị thiết kế — việc thực thi lịch backup thật cần môi
trường triển khai production, nằm ngoài phạm vi bàn giao học kỳ này theo
mục 1.6 của báo cáo.)*

---

## 9. Đánh giá Partitioning (đánh giá, chưa triển khai)

**Bảng có khả năng cần partition trong tương lai:** `inventory_transactions`
— là bảng duy nhất tăng trưởng không giới hạn theo thời gian (mọi giao dịch
tồn kho của mọi Tenant, mọi thời điểm, không bao giờ xóa vì append-only).

**Chiến lược đề xuất khi cần triển khai:** Partition theo RANGE trên
`created_at` (theo tháng), dùng Partition Function + Partition Scheme chuẩn
của SQL Server:
```sql
CREATE PARTITION FUNCTION pf_ledger_monthly (DATETIME)
AS RANGE RIGHT FOR VALUES ('2026-01-01','2026-02-01','2026-03-01', ...);

CREATE PARTITION SCHEME ps_ledger_monthly
AS PARTITION pf_ledger_monthly ALL TO ([PRIMARY]);
```
Lợi ích: partition elimination cho truy vấn báo cáo theo khoảng thời gian,
dễ archive/xóa dữ liệu quá cũ theo từng partition thay vì DELETE hàng loạt
(vốn bị chặn hoàn toàn bởi trigger append-only — càng cần partition để quản
lý vòng đời dữ liệu bằng cách SWITCH PARTITION thay vì DELETE).

**Tiêu chí quyết định khi nào triển khai thật (KHÔNG làm ngay bây giờ):**
- Số dòng `inventory_transactions` vượt ngưỡng ~10-20 triệu dòng, HOẶC
- Độ trễ truy vấn báo cáo (p95) vượt ngưỡng NFR-PERF-01 (2 giây/100.000 dòng)
  đo được thực tế trên dữ liệu production, HOẶC
- Một Tenant đơn lẻ chiếm tỷ trọng dữ liệu bất thường lớn so với các Tenant
  còn lại (data skew).

**Vì sao chưa triển khai ở v2.0:** ở quy mô đồ án/giai đoạn khởi điểm SaaS
(seed data vài nghìn dòng), 2 composite index `(tenant_id, created_at)` và
`(tenant_id, sku_id)` đã đủ đáp ứng NFR-PERF-01 mà không cần độ phức tạp vận
hành của partitioning (quản lý partition boundary, index maintenance theo
từng partition...). Triển khai partitioning quá sớm khi chưa cần là
over-engineering — đúng tinh thần "đánh giá nhưng chỉ triển khai khi quy mô
cần" đã đặt ra.

---

## 10. Tổng kết đối chiếu checklist Physical

| Yêu cầu | Trạng thái |
|---|---|
| SQL Server DDL | ✅ `schema.sql` v2.0 |
| PK/FK | ✅ 20 PK, 24 FK |
| CHECK constraints | ✅ 21 ràng buộc |
| UNIQUE constraints | ✅ 14 ràng buộc |
| Tenant isolation | ✅ Lớp 1 (cột tenant_id) đã có; Lớp 2 (RLS) đã thiết kế, chờ Backend để kích hoạt |
| Inventory reservation | ✅ Lock hint `WITH (UPDLOCK, ROWLOCK)` trên PK tự nhiên |
| WAC/average cost | ✅ `stock_balances.avg_cost` |
| Order cost snapshot | ✅ `order_items.cost_price NOT NULL` |
| Append-only ledger | ✅ `INSTEAD OF TRIGGER`, bổ sung `SET XACT_ABORT ON` |
| Index theo workload | ✅ 8 index, có bảng lý giải theo từng mẫu truy vấn |
| Backup/recovery | ✅ Chiến lược đầy đủ (mục 8), chưa thực thi vì chưa có môi trường production |
| Đánh giá OLTP | ✅ Mục 7 |
| Partitioning | ✅ Đã đánh giá + tiêu chí ngưỡng triển khai, chủ động CHƯA làm (mục 9) |
