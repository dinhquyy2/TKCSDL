# OISM - Data Dictionary (Từ điển Dữ liệu)

**Hệ quản trị CSDL:** SQL Server (T-SQL)
**Mục tiêu:** Mô tả chi tiết cấu trúc 17 bảng thuộc Mô hình dữ liệu Vật lý.

---

## 1. Bảng `tenants` (Hệ thống/Cửa hàng gốc)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| tenant_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính, định danh cửa hàng/doanh nghiệp |
| name | NVARCHAR(255) | NOT NULL | Tên cửa hàng/thương hiệu |
| domain | VARCHAR(100) | UNIQUE | Tên miền riêng của cửa hàng |
| status | VARCHAR(20) | DEFAULT 'ACTIVE' | Trạng thái hoạt động (ACTIVE/INACTIVE) |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo |
| updated_at | DATETIME | DEFAULT GETDATE() | Thời gian cập nhật cuối |

## 2. Bảng `branches` (Chi nhánh)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| branch_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính, định danh chi nhánh |
| tenant_id | UNIQUEIDENTIFIER | FK (tenants) ON DELETE CASCADE| Thuộc cửa hàng gốc nào |
| name | NVARCHAR(255) | NOT NULL | Tên chi nhánh |
| address | NVARCHAR(MAX) | | Địa chỉ chi nhánh |
| phone | VARCHAR(20) | | Số điện thoại liên hệ |
| is_active | BIT | DEFAULT 1 | 1 = Đang hoạt động, 0 = Đóng cửa |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo |
| updated_at | DATETIME | DEFAULT GETDATE() | Thời gian cập nhật cuối |

## 3. Bảng `users` (Người dùng/Nhân viên)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| user_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính, định danh nhân viên |
| tenant_id | UNIQUEIDENTIFIER | FK (tenants) ON DELETE CASCADE| Thuộc hệ thống nào |
| username | VARCHAR(100) | NOT NULL, UNIQUE | Tên đăng nhập |
| email | VARCHAR(255) | NOT NULL | Địa chỉ email |
| password_hash | VARCHAR(255) | NOT NULL | Mật khẩu đã được mã hóa (Hash) |
| full_name | NVARCHAR(255) | | Họ và tên nhân viên |
| role | VARCHAR(50) | NOT NULL | Vai trò (ADMIN, MANAGER, STAFF) |
| is_active | BIT | DEFAULT 1 | 1 = Đang làm việc, 0 = Đã nghỉ |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo |
| updated_at | DATETIME | DEFAULT GETDATE() | Thời gian cập nhật cuối |

## 4. Bảng `partners` (Đối tác: Khách hàng/Nhà cung cấp)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| partner_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính, định danh đối tác |
| tenant_id | UNIQUEIDENTIFIER | FK (tenants) ON DELETE CASCADE| Thuộc hệ thống nào |
| type | VARCHAR(50) | NOT NULL | Phân loại (CUSTOMER / SUPPLIER) |
| name | NVARCHAR(255) | NOT NULL | Tên khách hàng / Nhà cung cấp |
| phone | VARCHAR(20) | | Số điện thoại |
| email | VARCHAR(255) | | Email liên hệ |
| address | NVARCHAR(MAX) | | Địa chỉ |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo |
| updated_at | DATETIME | DEFAULT GETDATE() | Thời gian cập nhật |

## 5. Bảng `product_categories` (Danh mục sản phẩm)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| category_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính, định danh danh mục |
| tenant_id | UNIQUEIDENTIFIER | FK (tenants) ON DELETE CASCADE| Thuộc hệ thống nào |
| name | NVARCHAR(100) | NOT NULL | Tên danh mục (vd: Áo thun, Quần đùi) |
| description | NVARCHAR(MAX) | | Mô tả danh mục |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo |
| updated_at | DATETIME | DEFAULT GETDATE() | Thời gian cập nhật |

## 6. Bảng `products` (Sản phẩm gốc)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| product_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính, định danh sản phẩm |
| tenant_id | UNIQUEIDENTIFIER | FK (tenants) ON DELETE CASCADE| Thuộc hệ thống nào |
| category_id | UNIQUEIDENTIFIER | FK (product_categories) | Thuộc danh mục nào |
| name | NVARCHAR(255) | NOT NULL | Tên sản phẩm chung |
| description | NVARCHAR(MAX) | | Mô tả chi tiết sản phẩm |
| base_price | DECIMAL(15, 2) | | Giá niêm yết cơ bản |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo |
| updated_at | DATETIME | DEFAULT GETDATE() | Thời gian cập nhật |

## 7. Bảng `brands` (Thương hiệu)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| brand_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính, định danh thương hiệu |
| tenant_id | UNIQUEIDENTIFIER | FK (tenants) | Thuộc hệ thống nào |
| name | NVARCHAR(100) | NOT NULL | Tên thương hiệu |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo |

## 8. Bảng `sku_variants` (Biến thể sản phẩm/SKU)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| sku_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính, định danh SKU cụ thể |
| product_id | UNIQUEIDENTIFIER | FK (products) ON DELETE CASCADE| Thuộc sản phẩm gốc nào |
| sku_code | VARCHAR(50) | NOT NULL, UNIQUE | Mã SKU nội bộ (vd: TSHIRT-RED-XL) |
| color | NVARCHAR(50) | | Màu sắc |
| size | NVARCHAR(50) | | Kích cỡ |
| price | DECIMAL(15, 2) | NOT NULL | Giá bán chính thức của biến thể này |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo |
| updated_at | DATETIME | DEFAULT GETDATE() | Thời gian cập nhật |

## 9. Bảng `barcodes` (Mã vạch)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| barcode_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính |
| sku_id | UNIQUEIDENTIFIER | FK (sku_variants) ON DELETE CASCADE| Thuộc biến thể SKU nào |
| barcode | VARCHAR(100) | NOT NULL, UNIQUE | Chuỗi mã vạch để quét (EAN, UPC) |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo |

## 10. Bảng `stock_balances` (Tồn kho hiện tại)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| balance_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính |
| branch_id | UNIQUEIDENTIFIER | FK (branches) | Tồn tại chi nhánh nào |
| sku_id | UNIQUEIDENTIFIER | FK (sku_variants) | Của sản phẩm SKU nào |
| quantity | INT | DEFAULT 0 | Số lượng tồn kho thực tế |
| last_updated | DATETIME | DEFAULT GETDATE() | Lần cuối cùng cập nhật số lượng |
| *(Index/UQ)* | UNIQUE | (branch_id, sku_id) | Mỗi SKU chỉ có 1 dòng tồn tại 1 chi nhánh |

## 11. Bảng `inventory_transactions` (Sổ cái/Lịch sử kho)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| transaction_id| UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính |
| branch_id | UNIQUEIDENTIFIER | FK (branches) | Phát sinh tại chi nhánh nào |
| sku_id | UNIQUEIDENTIFIER | FK (sku_variants) | Liên quan đến sản phẩm SKU nào |
| transaction_type| VARCHAR(50) | NOT NULL | Loại giao dịch: IN, OUT, ADJUSTMENT |
| quantity | INT | NOT NULL | Số lượng (+ là nhập, - là xuất) |
| reference_id | UNIQUEIDENTIFIER | | ID tham chiếu đến Đơn hàng / Phiếu nhập |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian phát sinh giao dịch |

## 12. Bảng `orders` (Đơn hàng bán ra)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| order_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính |
| tenant_id | UNIQUEIDENTIFIER | FK (tenants) | Thuộc hệ thống nào |
| branch_id | UNIQUEIDENTIFIER | FK (branches) | Xuất phát từ chi nhánh nào |
| partner_id | UNIQUEIDENTIFIER | FK (partners) | Khách hàng mua (có thể NULL) |
| user_id | UNIQUEIDENTIFIER | FK (users) | Nhân viên tạo đơn |
| status | VARCHAR(50) | DEFAULT 'PENDING' | Trạng thái (PENDING, COMPLETED, CANCELLED) |
| total_amount | DECIMAL(15, 2) | NOT NULL | Tổng tiền đơn hàng |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo đơn |
| updated_at | DATETIME | DEFAULT GETDATE() | Thời gian cập nhật đơn |

## 13. Bảng `order_items` (Chi tiết đơn hàng)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| order_item_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính |
| order_id | UNIQUEIDENTIFIER | FK (orders) ON DELETE CASCADE | Thuộc đơn hàng nào |
| sku_id | UNIQUEIDENTIFIER | FK (sku_variants) | Sản phẩm SKU nào được mua |
| quantity | INT | NOT NULL | Số lượng mua |
| unit_price | DECIMAL(15, 2) | NOT NULL | Đơn giá lúc bán |
| subtotal | DECIMAL(15, 2) | NOT NULL | Thành tiền (quantity * unit_price) |

## 14. Bảng `purchase_receipts` (Phiếu nhập hàng)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| receipt_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính |
| tenant_id | UNIQUEIDENTIFIER | FK (tenants) | Thuộc hệ thống nào |
| branch_id | UNIQUEIDENTIFIER | FK (branches) | Nhập vào chi nhánh nào |
| partner_id | UNIQUEIDENTIFIER | FK (partners) | Nhà cung cấp nào giao hàng |
| status | VARCHAR(50) | DEFAULT 'DRAFT' | Trạng thái phiếu (DRAFT, COMPLETED) |
| total_amount | DECIMAL(15, 2) | NOT NULL | Tổng giá trị phiếu nhập |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo phiếu |

## 15. Bảng `purchase_receipt_items` (Chi tiết phiếu nhập)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| receipt_item_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính |
| receipt_id | UNIQUEIDENTIFIER | FK (purchase_receipts) ON DELETE CASCADE| Thuộc phiếu nhập nào |
| sku_id | UNIQUEIDENTIFIER | FK (sku_variants) | Mã sản phẩm SKU nhập |
| quantity | INT | NOT NULL | Số lượng nhập |
| cost_price | DECIMAL(15, 2) | NOT NULL | Giá vốn nhập vào |

## 16. Bảng `stock_transfers` (Phiếu điều chuyển kho)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| transfer_id | UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính |
| tenant_id | UNIQUEIDENTIFIER | FK (tenants) | Thuộc hệ thống nào |
| from_branch_id| UNIQUEIDENTIFIER | FK (branches) | Chi nhánh xuất hàng |
| to_branch_id | UNIQUEIDENTIFIER | FK (branches) | Chi nhánh nhận hàng |
| status | VARCHAR(50) | DEFAULT 'PENDING' | Trạng thái (PENDING, SHIPPING, COMPLETED) |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo phiếu |

## 17. Bảng `stock_transfer_items` (Chi tiết phiếu điều chuyển)

| Cột | Kiểu dữ liệu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| transfer_item_id| UNIQUEIDENTIFIER | PK, DEFAULT NEWID() | Khóa chính |
| transfer_id | UNIQUEIDENTIFIER | FK (stock_transfers) ON DELETE CASCADE| Thuộc phiếu chuyển nào |
| sku_id | UNIQUEIDENTIFIER | FK (sku_variants) | Sản phẩm SKU được chuyển |
| quantity | INT | NOT NULL | Số lượng chuyển |
