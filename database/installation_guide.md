# OISM — Hướng dẫn cài đặt Database (SQL Server)

Hướng dẫn này dùng **nguyên bản file của TV1** trong thư mục `database/`:
`schema.sql`, `ledger_constraints.sql`, `data.sql` — không viết lại schema.

---

## Bước 1 — Cài Docker

Cài Docker Desktop (Windows/Mac) hoặc Docker Engine (Linux). Kiểm tra:
```bash
docker --version
```

## Bước 2 — Kéo image SQL Server 2022 và chạy container

```bash
docker pull mcr.microsoft.com/mssql/server:2022-latest

docker run -e "ACCEPT_EULA=Y" \
           -e "MSSQL_SA_PASSWORD=OismStrongP@ss123" \
           -p 1433:1433 \
           --name oism-sqlserver \
           -d mcr.microsoft.com/mssql/server:2022-latest
```
Kiểm tra container đã chạy:
```bash
docker ps
```
Phải thấy `oism-sqlserver` ở trạng thái `Up`.

## Bước 3 — Kết nối và tạo database trống

Dùng `sqlcmd` (có sẵn trong container) hoặc SSMS/Azure Data Studio từ máy host.

**Cách nhanh nhất — chạy sqlcmd ngay trong container:**
```bash
docker exec -it oism-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "OismStrongP@ss123" -C \
  -Q "CREATE DATABASE OISM;"
```

**Hoặc dùng SSMS/Azure Data Studio** (khuyến nghị cho TV2 vì dễ xem lỗi trực quan):
- Server: `localhost,1433`
- Login: `sa` / mật khẩu ở Bước 2
- Chạy: `CREATE DATABASE OISM;`

## Bước 4 — Chạy 3 file theo ĐÚNG thứ tự

**Thứ tự bắt buộc** (sai thứ tự sẽ lỗi vì phụ thuộc bảng/trigger chưa tồn tại):

```bash
# 1. Tạo 20 bảng
docker exec -i oism-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "OismStrongP@ss123" -C -d OISM \
  -i database/schema.sql

# 2. Tạo trigger append-only (INSTEAD OF UPDATE, DELETE trên inventory_transactions)
docker exec -i oism-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "OismStrongP@ss123" -C -d OISM \
  -i database/ledger_constraints.sql

# 3. Nạp dữ liệu mẫu
docker exec -i oism-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "OismStrongP@ss123" -C -d OISM \
  -i database/data.sql
```

*(Nếu dùng SSMS/Azure Data Studio: mở từng file bằng File → Open → chạy bằng
nút Execute, đúng theo thứ tự 1 → 2 → 3 ở trên.)*

## Bước 5 — Verify: xác nhận trigger append-only hoạt động

Đây là bước quan trọng nhất — phải thấy **lỗi**, không phải "thành công":

```sql
UPDATE inventory_transactions SET quantity = 999
WHERE transaction_id = (SELECT TOP 1 transaction_id FROM inventory_transactions);
```

Kết quả đúng phải là:
```
Msg 50000, Level 16, State 1
inventory_transactions is append-only. UPDATE/DELETE is not allowed.
Use a compensating entry instead.
```

Nếu câu lệnh **chạy thành công** (không báo lỗi) → Bước 4.2 (`ledger_constraints.sql`)
chưa chạy hoặc chạy sai — quay lại kiểm tra.

## Bước 6 — Verify: dữ liệu mẫu đã nạp đủ

```sql
SELECT COUNT(*) AS so_tenant FROM tenants;          -- kỳ vọng: 1
SELECT COUNT(*) AS so_don_hang FROM orders;          -- kỳ vọng: 2
SELECT COUNT(*) AS so_dong_ledger FROM inventory_transactions; -- kỳ vọng: 5
SELECT branch_id, sku_id, on_hand, reserved, avg_cost
FROM stock_balances;  -- kiểm tra avg_cost = 52000 sau 2 đợt nhập (xem data.sql)
```

## Việc TV2 cần làm SAU khi hoàn tất 6 bước trên

1. Mở rộng `data.sql` — hiện chỉ có **1 Tenant**, nên thêm 1-2 Tenant nữa để
   test được cô lập dữ liệu đa Tenant (xem gợi ý ở mục dưới).
2. Viết `integrity_check.sql` (T-SQL) gồm 5 phần: đối chiếu Ledger↔StockBalance,
   đối chiếu `total_amount`↔`SUM(subtotal)`, test append-only (lặp lại Bước 5
   dưới dạng script có ghi log), test cô lập Tenant, test công thức WAC trên
   dữ liệu thật trong `stock_balances`.
3. Điền kết quả thật vào bảng "Kết quả kiểm thử" ở Chương 4 báo cáo.

### Mẫu thêm Tenant thứ 2 (tham khảo nhanh)
```sql
DECLARE @Tenant2 UNIQUEIDENTIFIER = NEWID();
INSERT INTO tenants (tenant_id, name, domain, status)
VALUES (@Tenant2, N'Cửa hàng XYZ', 'xyz.vn', 'ACTIVE');
-- lặp lại các bước branches/users/sales_channels/products/... cho @Tenant2
-- theo đúng cấu trúc data.sql đã có cho Tenant 1
```

---

## Lưu ý quan trọng

- Không dùng lại `schema.sql`/`data.sql` bản PostgreSQL đã viết trước đó —
  2 engine không tương thích cú pháp (`UUID` vs `UNIQUEIDENTIFIER`,
  `gen_random_uuid()` vs `NEWID()`, trigger `BEFORE` vs `INSTEAD OF`...).
- Nếu máy không cài được Docker, có thể dùng **SQL Server Express** cài trực
  tiếp (miễn phí, tải từ trang Microsoft) thay cho container — xem hướng dẫn
  chi tiết ở Phụ lục A bên dưới.

---

## Phụ lục A — Cài không cần Docker (SQL Server Express + SSMS)

Dành cho máy Windows, không rành dòng lệnh. Toàn bộ thao tác bằng chuột,
không cần gõ lệnh terminal.

1. **Tải và cài SQL Server 2022 Express** — vào
   https://www.microsoft.com/en-us/sql-server/sql-server-downloads → bấm
   Download dưới mục "Express" (miễn phí) → chạy file, chọn kiểu cài
   **Basic** → ghi nhớ tên instance hiện ra cuối cùng (thường là
   `SQLEXPRESS`).
2. **Tải và cài SSMS** — vào
   https://learn.microsoft.com/en-us/ssms/install/install → tải bản mới
   nhất (`vs_SSMS.exe`) → chạy Install, đợi xong.
3. **Kết nối SSMS vào SQL Server** — mở SSMS → hộp thoại "Connect to
   Server" → Server name gõ `localhost\SQLEXPRESS` (hoặc tên instance ở
   Bước 1) → Authentication chọn "Windows Authentication" → Connect.
4. **Tạo database trống tên OISM** — trong Object Explorer, chuột phải vào
   "Databases" → "New Database..." → gõ `OISM` → OK.
5. **Chạy `schema.sql`** — chọn database `OISM` ở ô dropdown trên thanh
   công cụ → File → Open → File... → chọn `schema.sql` → bấm **Execute**
   (F5) → đợi thấy "Commands completed successfully".
6. **Chạy `ledger_constraints.sql`** — lặp lại thao tác File → Open → File...
   → Execute (F5). Không được bỏ qua bước này (đây là trigger append-only).
7. **Chạy `data.sql`** — tương tự, File → Open → File... → Execute (F5).
8. **Kiểm tra trigger hoạt động đúng** — bấm "New Query", gõ:
   ```sql
   UPDATE inventory_transactions SET quantity = 999
   WHERE transaction_id = (SELECT TOP 1 transaction_id FROM inventory_transactions);
   ```
   rồi Execute (F5). Kết quả **đúng** phải là báo **lỗi đỏ**, không phải
   chạy thành công. Nếu chạy được không lỗi → Bước 6 chưa chạy đúng, quay
   lại kiểm tra.

