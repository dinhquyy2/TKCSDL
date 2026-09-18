# OISM - Data Dictionary (Từ điển Dữ liệu) — v2.0

**Hệ quản trị CSDL:** SQL Server (T-SQL)
**Mục tiêu:** Mô tả chi tiết cấu trúc 20 bảng thuộc Mô hình dữ liệu Vật lý v2.0.
**Thay đổi so với v1.0:** xem `LOGICAL_DESIGN.md` và `PHYSICAL_DESIGN.md` để biết đầy đủ lý do từng thay đổi.

---

## 1. `tenants`
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| tenant_id | UNIQUEIDENTIFIER | PK | Định danh cửa hàng/doanh nghiệp |
| name | NVARCHAR(255) | NOT NULL | Tên cửa hàng |
| domain | VARCHAR(100) | UNIQUE, NULL | Tên miền riêng |
| status | VARCHAR(20) | CHECK IN (ACTIVE,SUSPENDED,INACTIVE) | Trạng thái hoạt động |
| created_at / updated_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo/cập nhật |

## 2. `branches`
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| branch_id | UNIQUEIDENTIFIER | PK | Định danh chi nhánh |
| tenant_id | UNIQUEIDENTIFIER | FK → tenants | Thuộc Tenant nào |
| name, address, phone | NVARCHAR/VARCHAR | | Thông tin chi nhánh |
| is_active | BIT | DEFAULT 1 | Đang hoạt động / đã đóng |

## 3. `users`  *(SỬA: username/email nay UNIQUE theo Tenant thay vì toàn cục)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| user_id | UNIQUEIDENTIFIER | PK | Định danh người dùng |
| tenant_id | UNIQUEIDENTIFIER | FK → tenants | |
| username | VARCHAR(100) | UNIQUE(tenant_id, username) | Tên đăng nhập, duy nhất trong Tenant |
| email | VARCHAR(255) | UNIQUE(tenant_id, email) | |
| password_hash | VARCHAR(255) | NOT NULL | Mật khẩu đã hash |
| role | VARCHAR(50) | CHECK IN (Owner,Staff,Cashier) | Khớp đúng 3 vai trò SRS |

## 4. `partners`
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| partner_id | UNIQUEIDENTIFIER | PK | |
| type | VARCHAR(50) | CHECK IN (SUPPLIER,CUSTOMER) | Phân loại đối tác |
| name, phone, email, address | | | Thông tin liên hệ |

## 5. `sales_channels`  *(MỚI)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| channel_id | UNIQUEIDENTIFIER | PK | |
| tenant_id | UNIQUEIDENTIFIER | FK → tenants | |
| code | VARCHAR(30) | UNIQUE(tenant_id, code) | 'POS','SHOPEE','TIKTOK','LAZADA','ADMIN_MANUAL' |
| type | VARCHAR(20) | CHECK IN (OFFLINE,ONLINE) | Phân loại kênh |

## 6. `product_categories`  *(SỬA: thêm parent_id để phân cấp thật)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| category_id | UNIQUEIDENTIFIER | PK | |
| parent_id | UNIQUEIDENTIFIER | FK → product_categories (self), NULL | Danh mục cha (phân cấp) |
| name | NVARCHAR(100) | UNIQUE(tenant_id, name) | |

## 7. `brands`
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| brand_id | UNIQUEIDENTIFIER | PK | |
| name | NVARCHAR(100) | UNIQUE(tenant_id, name) | |

## 8. `products`  *(SỬA: thêm brand_id — bản v1.0 brands là bảng mồ côi)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| product_id | UNIQUEIDENTIFIER | PK | |
| category_id | UNIQUEIDENTIFIER | FK → product_categories, NULL | |
| brand_id | UNIQUEIDENTIFIER | FK → brands, NULL | **Mới** |
| base_price | DECIMAL(15,2) | CHECK ≥ 0 | Giá tham khảo (giá thật ở sku_variants.price) |

## 9. `sku_variants`  *(SỬA: thêm tenant_id, sku_code UNIQUE theo Tenant, thêm UNIQUE combo)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| sku_id | UNIQUEIDENTIFIER | PK | |
| tenant_id | UNIQUEIDENTIFIER | FK → tenants | **Mới** |
| product_id | UNIQUEIDENTIFIER | FK → products | |
| sku_code | VARCHAR(50) | UNIQUE(tenant_id, sku_code) | **Sửa từ UNIQUE toàn cục → theo Tenant (BR-03)** |
| color, size | NVARCHAR(50) | UNIQUE(product_id, color, size) | Chặn tạo trùng biến thể |
| price | DECIMAL(15,2) | CHECK ≥ 0 | Giá bán |

## 10. `barcodes`  *(SỬA: thêm tenant_id)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| barcode_id | UNIQUEIDENTIFIER | PK | |
| tenant_id | UNIQUEIDENTIFIER | FK → tenants | **Mới**, denormalized có chủ đích |
| code | VARCHAR(100) | UNIQUE toàn hệ thống | Mã vạch thật (EAN-13), chuẩn toàn cầu |

## 11. `stock_balances`  *(SỬA LỚN NHẤT: thêm reserved, avg_cost, available; đổi PK)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| tenant_id | UNIQUEIDENTIFIER | FK → tenants | **Mới** |
| branch_id | UNIQUEIDENTIFIER | PK (phần 1), FK → branches | |
| sku_id | UNIQUEIDENTIFIER | PK (phần 2), FK → sku_variants | **PK đổi từ surrogate sang (branch_id, sku_id)** |
| on_hand | NUMERIC(14,3) | CHECK ≥ 0 | Tồn kho vật lý (đổi tên từ `quantity`) |
| reserved | NUMERIC(14,3) | CHECK ≥ 0 | **Mới** — số đã giữ chỗ cho đơn Reserved |
| avg_cost | NUMERIC(14,4) | CHECK ≥ 0 | **Mới** — giá vốn bình quân gia quyền (WAC) |
| available | NUMERIC (computed) | = on_hand - reserved, PERSISTED | **Mới** — tồn khả dụng, có index riêng |

## 12. `inventory_transactions`  *(SỬA: thêm tenant_id, balance_after, reference_type)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| transaction_id | UNIQUEIDENTIFIER | PK | |
| tenant_id | UNIQUEIDENTIFIER | FK → tenants | **Mới — bắt buộc cho NFR-TENANT-02** |
| transaction_type | VARCHAR(3) | CHECK IN (IN,OUT) | |
| quantity | NUMERIC(14,3) | CHECK > 0 | |
| balance_after | NUMERIC(14,3) | NOT NULL | **Mới** — số dư sau giao dịch, phục vụ audit |
| reference_type | VARCHAR(30) | CHECK IN (ORDER, PURCHASE_RECEIPT, STOCK_TRANSFER, STOCKTAKE_ADJUSTMENT) | **Mới** |
| *(không có updated_at/deleted_at)* | | | Bảng append-only — xem `ledger_constraints.sql` |

## 13. `stocktakes`  *(MỚI — v1.0 bỏ sót hoàn toàn, vi phạm FR-INV-04)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| stocktake_id | UNIQUEIDENTIFIER | PK | |
| status | VARCHAR(20) | CHECK IN (InProgress,Completed) | |

## 14. `stocktake_items`  *(MỚI)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| stocktake_item_id | UNIQUEIDENTIFIER | PK | |
| counted_qty | NUMERIC(14,3) | CHECK ≥ 0 | Số đếm thực tế |
| system_qty | NUMERIC(14,3) | NOT NULL | Số hệ thống tại thời điểm kiểm |
| variance_qty | NUMERIC (computed) | = counted_qty - system_qty | Chênh lệch, không lưu trùng |
| *(unique)* | | UNIQUE(stocktake_id, sku_id) | 1 SKU chỉ 1 dòng/phiên kiểm |

## 15. `orders`  *(SỬA: thêm channel_id, status có CHECK đúng state machine)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| order_id | UNIQUEIDENTIFIER | PK | |
| channel_id | UNIQUEIDENTIFIER | FK → sales_channels, NOT NULL | **Mới — v1.0 không có cách nào biết kênh bán** |
| status | VARCHAR(20) | CHECK IN (Draft,Reserved,Confirmed,Completed,Cancelled) | **Sửa: khớp đúng Order State Machine SRS** |
| total_amount | DECIMAL(15,2) | CHECK ≥ 0 | Cache = SUM(order_items.subtotal), denormalized có chủ đích |

## 16. `order_items`  *(SỬA: thêm cost_price, tenant_id, UNIQUE, subtotal→computed)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| order_item_id | UNIQUEIDENTIFIER | PK | |
| tenant_id | UNIQUEIDENTIFIER | FK → tenants | **Mới** |
| cost_price | DECIMAL(15,4) | NOT NULL, CHECK ≥ 0 | **Mới — snapshot giá vốn, BR-04** |
| subtotal | DECIMAL (computed) | = quantity * unit_price | **Sửa: từ cột lưu cứng → computed (loại dữ liệu dư thừa)** |
| *(unique)* | | UNIQUE(order_id, sku_id) | **Mới** — chặn trùng SKU trong 1 đơn |

## 17. `purchase_receipts`  *(SỬA: status có CHECK)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| receipt_id | UNIQUEIDENTIFIER | PK | |
| status | VARCHAR(20) | CHECK IN (Draft,Confirmed) | **Mới** |

## 18. `purchase_receipt_items`  *(SỬA: thêm tenant_id, UNIQUE)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| receipt_item_id | UNIQUEIDENTIFIER | PK | |
| tenant_id | UNIQUEIDENTIFIER | FK → tenants | **Mới** |
| cost_price | DECIMAL(15,4) | CHECK ≥ 0 | Giá nhập — nguồn tính WAC |
| *(unique)* | | UNIQUE(receipt_id, sku_id) | **Mới** |

## 19. `stock_transfers`  *(SỬA: status có CHECK, thêm CHECK 2 chi nhánh khác nhau)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| transfer_id | UNIQUEIDENTIFIER | PK | |
| status | VARCHAR(20) | CHECK IN (InTransit,Completed) | **Mới, khớp đúng FR-INV-03** |
| *(check)* | | from_branch_id <> to_branch_id | **Mới** — chặn chuyển kho về chính nó |

## 20. `stock_transfer_items`  *(SỬA: thêm tenant_id, UNIQUE)*
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| transfer_item_id | UNIQUEIDENTIFIER | PK | |
| tenant_id | UNIQUEIDENTIFIER | FK → tenants | **Mới** |
| *(unique)* | | UNIQUE(transfer_id, sku_id) | **Mới** |

---

## Tổng hợp thay đổi so với v1.0

| Loại thay đổi | Số lượng | Chi tiết |
|---|---|---|
| Bảng mới thêm | 3 | `sales_channels`, `stocktakes`, `stocktake_items` |
| Cột mới thêm (nghiệp vụ) | 5 | `stock_balances.reserved/avg_cost`, `order_items.cost_price`, `orders.channel_id`, `inventory_transactions.balance_after` |
| Cột `tenant_id` bổ sung | 9 bảng | sku_variants, barcodes, stock_balances, inventory_transactions, order_items, purchase_receipt_items, stock_transfer_items, stocktakes, stocktake_items |
| CHECK constraint bổ sung cho status | 4 bảng | orders, purchase_receipts, stock_transfers, stocktakes |
| Cột lưu cứng → computed column | 3 | `order_items.subtotal`, `stocktake_items.variance_qty`, `stock_balances.available` (mới) |
| UNIQUE constraint bổ sung | 6 | order_items, sku_variants(x2), purchase_receipt_items, stock_transfer_items, stocktake_items |
| Sửa phạm vi UNIQUE (toàn cục → theo Tenant) | 2 | `users.username`, `sku_variants.sku_code` |
