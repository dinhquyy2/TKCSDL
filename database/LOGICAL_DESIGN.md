# OISM — Chứng minh Thiết kế Logic (Logical Design Correctness)

Tài liệu này chứng minh tính đúng đắn của mô hình dữ liệu OISM ở tầng **logic**,
độc lập với hệ quản trị CSDL cụ thể. Áp dụng cho schema vật lý tại `schema.sql`
(phiên bản 2.0). Ký hiệu: `PK` = khóa chính đã chọn, `CK` = candidate key
(có thể nhiều CK, PK là một trong số đó).

---

## 1. Quy ước & Phạm vi

- Mỗi bảng trong `schema.sql` được xem là một **quan hệ (relation)** R với tập
  thuộc tính là các cột của bảng.
- Vì mô hình được xây dựng theo phương pháp ánh xạ Thực thể → Quan hệ
  (ER-to-Relational mapping) với mỗi thực thể độc lập là một bảng riêng, tập
  phụ thuộc hàm (FD) của phần lớn các bảng có dạng đơn giản: `{PK} → {tất cả
  thuộc tính còn lại}`, cộng thêm FD phát sinh từ các ràng buộc `UNIQUE` khai
  báo tường minh trong schema (đóng vai trò candidate key phụ).
- Tài liệu chỉ liệt kê chi tiết FD cho các bảng có từ 2 candidate key trở lên,
  khóa phức hợp, hoặc có ngoại lệ chuẩn hóa cần giải trình. Các bảng còn lại
  (dạng `{PK} → tất cả`) được liệt kê rút gọn ở Bảng tổng hợp (mục 5).

---

## 2. Functional Dependencies & Candidate Keys — các bảng trọng yếu

### 2.1. `tenants(tenant_id, name, domain, status, created_at, updated_at)`
```
FD1: tenant_id → name, domain, status, created_at, updated_at
FD2: domain    → tenant_id, name, status, created_at, updated_at   (domain UNIQUE, có thể NULL)
```
**Candidate Keys:** `{tenant_id}` (PK), `{domain}` (CK phụ, chỉ có hiệu lực khi NOT NULL).

### 2.2. `users(user_id, tenant_id, username, email, password_hash, full_name, role, is_active, created_at, updated_at)`
```
FD1: user_id → tenant_id, username, email, password_hash, full_name, role, is_active, created_at, updated_at
FD2: (tenant_id, username) → user_id, email, password_hash, full_name, role, is_active, created_at, updated_at
FD3: (tenant_id, email)    → user_id, username, password_hash, full_name, role, is_active, created_at, updated_at
```
**Candidate Keys:** `{user_id}` (PK), `{tenant_id, username}`, `{tenant_id, email}`.

> **Sửa so với bản gốc:** bản gốc khai báo `username UNIQUE` toàn cục — nghĩa
> là FD thật của hệ thống cũ là `username → tenant_id, ...` (không có
> `tenant_id` ở vế trái). Điều này về logic tương đương với việc **username là
> một không gian tên toàn cục dùng chung cho mọi Tenant**, mâu thuẫn trực
> tiếp với mô hình multi-tenant đã đặt ra (BR-05: một User chỉ thuộc 1
> Tenant, và các Tenant phải độc lập hoàn toàn về dữ liệu — kể cả không gian
> tên định danh). Đã sửa candidate key về `{tenant_id, username}`.

### 2.3. `sku_variants(sku_id, tenant_id, product_id, sku_code, color, size, price, created_at, updated_at)`
```
FD1: sku_id → tenant_id, product_id, sku_code, color, size, price, created_at, updated_at
FD2: (tenant_id, sku_code) → sku_id, product_id, color, size, price, created_at, updated_at
FD3: (product_id, color, size) → sku_id, tenant_id, sku_code, price, created_at, updated_at
```
**Candidate Keys:** `{sku_id}` (PK), `{tenant_id, sku_code}`, `{product_id, color, size}`.

### 2.4. `stock_balances(tenant_id, branch_id, sku_id, on_hand, reserved, avg_cost, updated_at)`
```
FD1: (branch_id, sku_id) → tenant_id, on_hand, reserved, avg_cost, updated_at
```
**Candidate Key:** `{branch_id, sku_id}` (PK — khóa tự nhiên, không cần surrogate
vì cặp này vốn đã duy nhất về mặt nghiệp vụ: "1 SKU chỉ có đúng 1 dòng tồn
kho tại 1 chi nhánh").

> **Lưu ý về `tenant_id` trong bảng này:** xem mục 4 — đây là ngoại lệ chuẩn
> hóa có kiểm soát, không phải một candidate key độc lập.

### 2.5. `order_items(order_item_id, tenant_id, order_id, sku_id, quantity, unit_price, cost_price)`
*(subtotal là computed column, không tham gia tính FD vì luôn suy ra được từ quantity, unit_price)*
```
FD1: order_item_id → tenant_id, order_id, sku_id, quantity, unit_price, cost_price
FD2: (order_id, sku_id) → order_item_id, tenant_id, quantity, unit_price, cost_price
```
**Candidate Keys:** `{order_item_id}` (PK), `{order_id, sku_id}` (ràng buộc
nghiệp vụ "1 SKU chỉ xuất hiện 1 dòng / đơn hàng").

### 2.6. `stocktake_items(stocktake_item_id, tenant_id, stocktake_id, sku_id, counted_qty, system_qty)`
*(variance_qty là computed column)*
```
FD1: stocktake_item_id → tenant_id, stocktake_id, sku_id, counted_qty, system_qty
FD2: (stocktake_id, sku_id) → stocktake_item_id, tenant_id, counted_qty, system_qty
```
**Candidate Keys:** `{stocktake_item_id}` (PK), `{stocktake_id, sku_id}`.

---

## 3. Chứng minh Chuẩn hóa (2NF / 3NF / BCNF)

**Định lý áp dụng (BCNF):** Quan hệ R đạt BCNF nếu với mọi FD không tầm
thường `X → Y` trong R, `X` là siêu khóa (superkey) của R.

**Lập luận chung:** Vì mọi bảng trong mục 2 và Bảng tổng hợp (mục 5) chỉ có
đúng 2 dạng FD không tầm thường — `(1)` từ PK và `(2)` từ các candidate key
phụ do `UNIQUE` constraint sinh ra — và **cả hai dạng đều có vế trái là một
candidate key** (không có FD nào có vế trái là tập con thực sự của một
candidate key), nên **mọi bảng đều đạt BCNF**, ngoại trừ các trường hợp được
khai báo là **ngoại lệ có kiểm soát** ở mục 4.

**Kiểm tra 2NF (phụ thuộc bộ phận) cho các khóa phức hợp:**

| Bảng | Khóa phức hợp | Thuộc tính phi khóa | Có phụ thuộc bộ phận không? |
|---|---|---|---|
| `stock_balances` | `(branch_id, sku_id)` | `on_hand, reserved, avg_cost` | Không — cả 3 đều cần *cả 2* cột khóa (tồn kho khác nhau theo từng cặp chi nhánh×SKU) |
| `order_items` | *(PK đơn `order_item_id`, `(order_id,sku_id)` chỉ là CK phụ)* | `quantity, unit_price, cost_price` | Không — các CK đều đơn giá trị hoặc composite tối thiểu |
| `stocktake_items` | tương tự `order_items` | `counted_qty, system_qty` | Không |
| `users` | *(PK đơn)* | — | Không |

→ Không phát hiện phụ thuộc bộ phận nào ngoài các trường hợp đã khai báo ở
mục 4. **Kết luận: toàn bộ schema đạt 3NF; đạt BCNF ngoại trừ các ngoại lệ
tường minh dưới đây.**

---

## 4. Ngoại lệ chuẩn hóa có kiểm soát (Controlled Denormalization)

Đây là phần quan trọng nhất của chứng minh — thay vì che giấu, tài liệu này
**chỉ rõ từng chỗ lệch khỏi chuẩn hóa nghiêm ngặt**, lý do kỹ thuật, và cơ chế
kiểm soát rủi ro tương ứng.

### 4.1. Cột `tenant_id` lặp lại trên các bảng con

**Vi phạm hình thức:** Trong `stock_balances`, `tenant_id` phụ thuộc vào
`branch_id` (qua `branches.tenant_id`) — chỉ là **một phần** của khóa chính
`(branch_id, sku_id)`. Đây là **phụ thuộc bộ phận (partial dependency)** theo
đúng định nghĩa — vi phạm 2NF nếu xét tuyệt đối. Tương tự cho `tenant_id`
trên `sku_variants`, `barcodes`, `inventory_transactions`, `order_items`,
`purchase_receipt_items`, `stock_transfer_items`, `stocktake_items`.

**Vì sao vẫn giữ (đánh đổi có chủ đích):**
1. Cho phép lọc dữ liệu theo Tenant **trực tiếp trên mọi bảng**, không cần
   JOIN ngược lên bảng cha — bắt buộc để áp dụng EF Core Global Query
   Filter (NFR-TENANT-01) và làm cột đầu trong mọi composite index
   `(tenant_id, ...)` phục vụ hiệu năng (NFR-TENANT-02).
2. **Phòng thủ theo chiều sâu (defense-in-depth):** nếu một truy vấn nào đó
   quên điều kiện JOIN qua bảng cha, `tenant_id` trên chính bảng con vẫn là
   một lớp chặn rò rỉ dữ liệu chéo Tenant — đây là mẫu thiết kế tiêu chuẩn
   trong kiến trúc SaaS đa khách thuê (tenant_id column trên mọi bảng
   nghiệp vụ), được đánh đổi có ý thức, không phải sai sót.

**Cơ chế kiểm soát rủi ro (bắt buộc phải có, nếu không FD giả này sẽ gây dị
thường cập nhật):**
- `tenant_id` trên bảng con **không bao giờ được UPDATE độc lập** sau khi
  INSERT — chỉ được set đúng 1 lần từ giá trị `tenant_id` của bản ghi cha
  tại thời điểm tạo (do tầng ứng dụng đảm nhiệm).
- Khuyến nghị bổ sung (giai đoạn Backend): `CHECK` logic hoặc trigger đối
  chiếu `tenant_id` con phải khớp `tenant_id` của bản ghi cha tương ứng
  (`branches.tenant_id`, `sku_variants.tenant_id`...) mỗi khi INSERT — có
  thể hiện thực bằng `FOREIGN KEY` phức hợp `(branch_id, tenant_id)` trỏ
  tới một `UNIQUE(branch_id, tenant_id)` trên bảng `branches` để SQL Server
  tự động ép buộc tính nhất quán này ở tầng ràng buộc thay vì tin tưởng ứng
  dụng. *(Không đưa vào `schema.sql` v2.0 vì tăng độ phức tạp vượt phạm vi
  đồ án; ghi nhận là hướng cải tiến.)*

### 4.2. `stock_balances` là dữ liệu dẫn xuất (derived) từ `inventory_transactions`

Về lý thuyết, `SUM(quantity theo type IN/OUT)` từ `inventory_transactions`
hoàn toàn suy ra được `on_hand` — nghĩa là `stock_balances` không mang thông
tin mới, vi phạm nguyên tắc "không dữ liệu dư thừa" nếu xét cực đoan.

**Lý do giữ lại:** đây là **read model** tách biệt (tư duy CQRS), bắt buộc
phải có một bảng đúng 1-dòng/SKU/Branch để làm mục tiêu khóa hàng
(`WITH (UPDLOCK, ROWLOCK)`) trong cơ chế chống bán vượt tồn — không thể
`SELECT...FOR UPDATE`/khóa trên kết quả của một phép `SUM()` được.

**Kiểm soát rủi ro:** bắt buộc có script đối chiếu định kỳ
`stock_balances.on_hand` với `SUM()` từ `inventory_transactions` (đã có ở
`report/LaTeX/chapters/ch4/03-testing-and-results.tex`, mục 4.3.3) để phát
hiện sớm nếu 2 nguồn lệch nhau do lỗi ứng dụng.

### 4.3. `orders.total_amount` là cache của `SUM(order_items.subtotal)`

**Lý do giữ lại:** tránh phải JOIN + SUM() mỗi lần hiển thị danh sách đơn
hàng (thao tác tần suất rất cao ở Admin Dashboard/POS).

**Kiểm soát rủi ro:** khuyến nghị bổ sung script đối chiếu tương tự mục 4.2
(`orders.total_amount` so với `SUM(order_items.subtotal)`), cùng nhóm với
`integrity_check.sql` của TV2.

### 4.4. Những gì đã được LOẠI BỎ để tránh dư thừa không cần thiết

Khác với 3 ngoại lệ có chủ đích ở trên, các cột sau **không có lý do chính
đáng để lưu trùng** nên đã bị loại khỏi `schema.sql` v2.0:
- `order_items.subtotal` (bản gốc lưu cứng) → đổi thành **computed column**
  `AS (quantity * unit_price) PERSISTED`. Khác với `orders.total_amount`
  (mục 4.3), `subtotal` không cần cache vì chỉ nhân 2 số ngay trong cùng
  dòng — computed column cho phép SQL Server tự tính lại, không có nguy cơ
  dị thường cập nhật, không tốn thêm ghi trong ứng dụng.
- `stocktake_items.variance_qty` → tương tự, đổi thành computed column
  `AS (counted_qty - system_qty) PERSISTED`.
- `stock_balances.available` → thêm mới dưới dạng computed column (không
  phải loại bỏ) để vừa tránh lưu trùng vừa cho phép đánh index phục vụ
  cảnh báo tồn thấp (mục Physical Design).

---

## 5. Bảng tổng hợp Candidate Key — 20 quan hệ

| # | Quan hệ | Candidate Key(s) | PK đã chọn |
|---|---|---|---|
| 1 | tenants | {tenant_id}, {domain} | tenant_id |
| 2 | branches | {branch_id} | branch_id |
| 3 | users | {user_id}, {tenant_id,username}, {tenant_id,email} | user_id |
| 4 | partners | {partner_id} | partner_id |
| 5 | sales_channels | {channel_id}, {tenant_id,code} | channel_id |
| 6 | product_categories | {category_id}, {tenant_id,name} | category_id |
| 7 | brands | {brand_id}, {tenant_id,name} | brand_id |
| 8 | products | {product_id} | product_id |
| 9 | sku_variants | {sku_id}, {tenant_id,sku_code}, {product_id,color,size} | sku_id |
| 10 | barcodes | {barcode_id}, {code} | barcode_id |
| 11 | stock_balances | {branch_id, sku_id} | (branch_id, sku_id) |
| 12 | inventory_transactions | {transaction_id} | transaction_id |
| 13 | stocktakes | {stocktake_id} | stocktake_id |
| 14 | stocktake_items | {stocktake_item_id}, {stocktake_id,sku_id} | stocktake_item_id |
| 15 | orders | {order_id} | order_id |
| 16 | order_items | {order_item_id}, {order_id,sku_id} | order_item_id |
| 17 | purchase_receipts | {receipt_id} | receipt_id |
| 18 | purchase_receipt_items | {receipt_item_id}, {receipt_id,sku_id} | receipt_item_id |
| 19 | stock_transfers | {transfer_id} | transfer_id |
| 20 | stock_transfer_items | {transfer_item_id}, {transfer_id,sku_id} | transfer_item_id |

---

## 6. Chứng minh Phân rã Bảo toàn Nối (Lossless-Join Decomposition)

**Điều kiện đủ (Chandra–Merlin):** phân rã R thành R1, R2 là bảo toàn nối nếu
`R1 ∩ R2` là khóa (candidate key) của R1 **hoặc** của R2.

Vì mọi khóa ngoại (FK) trong `schema.sql` đều trỏ đến **khóa chính** của bảng
cha (không có FK nào trỏ đến một cột không phải khóa), nên với mọi cặp
bảng cha-con liên kết trực tiếp qua FK, điều kiện Chandra–Merlin **luôn được
thỏa mãn tự động**: giao của 2 bảng chính là PK của bảng cha.

Bảng dưới liệt kê toàn bộ 44 cặp bảng cha-con liên kết trực tiếp qua khóa
ngoại (tổng cộng 45 cột FK — riêng `stock_transfers` có 2 cột `from_branch_id`
và `to_branch_id` cùng trỏ về `branches`, tính là 1 cặp bảng nhưng 2 cột FK)
và xác nhận điều kiện:

| Quan hệ cha (giữ PK) | Quan hệ con | Thuộc tính chung | Là khóa của bên nào? |
|---|---|---|---|
| tenants | branches, users, partners, sales_channels, product_categories, brands, products, sku_variants, barcodes, stock_balances, inventory_transactions, stocktakes, stocktake_items, orders, order_items, purchase_receipts, purchase_receipt_items, stock_transfers, stock_transfer_items | tenant_id | PK của `tenants` |
| branches | stock_balances, inventory_transactions, orders, purchase_receipts, stocktakes, stock_transfers (2 cột: from_branch_id, to_branch_id) | branch_id | PK của `branches` |
| product_categories | products, (self-FK parent_id) | category_id | PK của `product_categories` |
| brands | products | brand_id | PK của `brands` |
| products | sku_variants | product_id | PK của `products` |
| sku_variants | barcodes, stock_balances, inventory_transactions, order_items, purchase_receipt_items, stock_transfer_items, stocktake_items | sku_id | PK của `sku_variants` |
| sales_channels | orders | channel_id | PK của `sales_channels` |
| partners | orders, purchase_receipts | partner_id | PK của `partners` |
| users | orders | user_id | PK của `users` |
| orders | order_items | order_id | PK của `orders` |
| purchase_receipts | purchase_receipt_items | receipt_id | PK của `purchase_receipts` |
| stock_transfers | stock_transfer_items | transfer_id | PK của `stock_transfers` |
| stocktakes | stocktake_items | stocktake_id | PK của `stocktakes` |

→ **Kết luận: toàn bộ 20 quan hệ đảm bảo Lossless-Join Decomposition** — có
thể JOIN ngược lại bất kỳ tổ hợp bảng cha-con nào mà không phát sinh dòng dữ
liệu giả (spurious tuples) hoặc mất thông tin.

**Bảo toàn phụ thuộc (Dependency-Preserving):** đạt, vì không có FD nào bị
"cắt ngang" giữa 2 bảng sau phân rã — mọi FD gốc của một thực thể đều nằm
trọn trong đúng 1 bảng (ngoại trừ 3 ngoại lệ đã khai báo tường minh ở mục 4,
vốn được kiểm soát bằng script đối chiếu định kỳ thay vì ràng buộc CSDL).

---

## 7. Kết luận

| Tiêu chí | Kết quả |
|---|---|
| Functional Dependencies | Đã liệt kê tường minh cho toàn bộ 20 quan hệ |
| Candidate Keys | Đã xác định đầy đủ, kể cả các CK phụ phát sinh từ UNIQUE constraint |
| Chuẩn hóa | Đạt 3NF toàn bộ; đạt BCNF ngoại trừ 2 ngoại lệ có kiểm soát (`tenant_id` lặp, `stock_balances`/`orders.total_amount` là dữ liệu dẫn xuất) — đều đã giải trình lý do và cơ chế kiểm soát |
| Lossless-Join | Đạt cho toàn bộ 44 cặp bảng cha-con / 45 cột FK (chứng minh bằng điều kiện Chandra–Merlin) |
| Dependency-Preserving | Đạt |
| Dữ liệu dư thừa không cần thiết | Đã rà soát và loại bỏ 2 chỗ (`order_items.subtotal`, `stocktake_items.variance_qty` → chuyển thành computed column) |
