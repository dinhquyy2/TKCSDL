-- =====================================================
-- SEED DATA - SQL SERVER
-- Hệ thống quản lý bán hàng và tồn kho đa kênh
-- =====================================================

-- =====================================================
-- 1. TENANTS
-- =====================================================

INSERT INTO tenants (tenant_id, name, domain, status)
VALUES
('AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', N'Cửa hàng ABC', 'abc.vn', 'ACTIVE'),
('BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB', N'Cửa hàng XYZ', 'xyz.vn', 'ACTIVE'),
('CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC', N'Cửa hàng DEF', 'def.vn', 'ACTIVE');


-- =====================================================
-- 2. BRANCHES
-- =====================================================

INSERT INTO branches
(branch_id, tenant_id, name, address, phone)
VALUES
('A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 N'Chi nhánh Quận 1',
 N'123 Nguyễn Huệ, Quận 1, TP.HCM',
 '0901000001'),

('A1000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 N'Chi nhánh Quận 3',
 N'456 Võ Văn Tần, Quận 3, TP.HCM',
 '0901000002'),

('B1000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 N'Chi nhánh Trung tâm',
 N'789 Lê Lợi, Quận 1, TP.HCM',
 '0902000001');


-- =====================================================
-- 3. USERS
-- =====================================================

INSERT INTO users
(user_id, tenant_id, username, email, password_hash, full_name, role)
VALUES
('A2000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'admin_abc',
 'admin@abc.vn',
 '123456',
 N'Nguyễn Văn An',
 'OWNER'),

('A2000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'staff_abc',
 'staff@abc.vn',
 '123456',
 N'Trần Văn Bình',
 'STAFF'),

('A2000003-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'cashier_abc',
 'cashier@abc.vn',
 '123456',
 N'Lê Văn Cường',
 'CASHIER'),

('B2000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'admin_xyz',
 'admin@xyz.vn',
 '123456',
 N'Phạm Văn Dũng',
 'OWNER'),

('B2000002-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'staff_xyz',
 'staff@xyz.vn',
 '123456',
 N'Hoàng Văn Em',
 'STAFF');


-- =====================================================
-- 4. PARTNERS
-- =====================================================

INSERT INTO partners
(partner_id, tenant_id, type, name, phone, email, address)
VALUES
('A3000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'SUPPLIER',
 N'Công ty TNHH Điện tử ABC',
 '0903000001',
 'supplier@abc.vn',
 N'TP.HCM'),

('A3000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'CUSTOMER',
 N'Nguyễn Minh Khách',
 '0903000002',
 'customer1@gmail.com',
 N'TP.HCM'),

('B3000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'SUPPLIER',
 N'Công ty Điện tử XYZ',
 '0903000003',
 'supplier@xyz.vn',
 N'TP.HCM');


-- =====================================================
-- 5. PRODUCT CATEGORIES
-- =====================================================

INSERT INTO product_categories
(category_id, tenant_id, name, description)
VALUES
('A4000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 N'Điện thoại',
 N'Điện thoại thông minh'),

('A4000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 N'Laptop',
 N'Máy tính xách tay'),

('B4000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 N'Phụ kiện',
 N'Phụ kiện điện tử');


-- =====================================================
-- 6. PRODUCTS
-- =====================================================

INSERT INTO products
(product_id, tenant_id, category_id, name, description, base_price)
VALUES
('A5000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A4000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 N'Samsung Galaxy S24',
 N'Điện thoại thông minh Samsung Galaxy S24',
 20000000),

('A5000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A4000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 N'MacBook Air M2',
 N'Máy tính xách tay Apple MacBook Air M2',
 25000000),

('B5000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'B4000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 N'Xiaomi Redmi Buds',
 N'Tai nghe không dây Xiaomi Redmi Buds',
 1000000);


-- =====================================================
-- 7. BRANDS
-- =====================================================

INSERT INTO brands
(brand_id, tenant_id, name)
VALUES
('A6000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 N'Samsung'),

('A6000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 N'Apple'),

('B6000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 N'Xiaomi');


-- =====================================================
-- 8. SKU VARIANTS
-- =====================================================

INSERT INTO sku_variants
(sku_id, product_id, sku_code, color, size, price)
VALUES
('A7000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A5000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'S24-BLK-256',
 N'Đen',
 N'256GB',
 20000000),

('A7000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A5000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'MBA-M2-SLV',
 N'Bạc',
 N'256GB',
 25000000),

('B7000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'B5000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'REDBUDS-WHT',
 N'Trắng',
 N'Standard',
 1000000);


-- =====================================================
-- 9. BARCODES
-- =====================================================

INSERT INTO barcodes
(barcode_id, sku_id, barcode)
VALUES
('A8000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A7000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 '893100000001'),

('A8000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A7000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 '893100000002'),

('B8000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'B7000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 '893100000003');


-- =====================================================
-- 10. INITIAL STOCK BALANCE
-- =====================================================

-- Kho ban đầu:
-- Samsung Galaxy S24: 20 sản phẩm
-- MacBook Air M2: 10 sản phẩm
-- Xiaomi Redmi Buds: 30 sản phẩm

INSERT INTO stock_balances
(balance_id, branch_id, sku_id, quantity)
VALUES
('A9000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A7000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 19),

('A9000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A7000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 10),

('B9000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'B1000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'B7000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 30);


-- =====================================================
-- 11. INVENTORY TRANSACTIONS
-- =====================================================

-- Nhập tồn kho ban đầu

INSERT INTO inventory_transactions
(transaction_id, branch_id, sku_id, transaction_type, quantity, reference_id)
VALUES
('AA100001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A7000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'IN',
 20,
 NULL),

('AA100002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A7000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'IN',
 10,
 NULL),

('BB100001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'B1000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'B7000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'IN',
 30,
 NULL);


-- =====================================================
-- 12. ORDERS - 5 TRẠNG THÁI
-- =====================================================

INSERT INTO orders
(order_id, tenant_id, branch_id, partner_id, user_id, status, total_amount)
VALUES
('AA200001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A3000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A2000003-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'Draft',
 20000000),

('AA200002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A3000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A2000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'Reserved',
 20000000),

('AA200003-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A1000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A3000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A2000003-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'Confirmed',
 25000000),

('AA200004-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A3000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A2000003-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'Completed',
 20000000),

('BB200001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'B1000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 NULL,
 'B2000002-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'Cancelled',
 1000000);


-- =====================================================
-- 13. ORDER ITEMS
-- =====================================================

INSERT INTO order_items
(order_item_id, order_id, sku_id, quantity, unit_price, subtotal)
VALUES
('AA300001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AA200001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A7000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 1,
 20000000,
 20000000),

('AA300002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AA200002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A7000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 1,
 20000000,
 20000000),

('AA300003-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AA200003-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A7000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 1,
 25000000,
 25000000),

('AA300004-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'AA200004-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A7000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 1,
 20000000,
 20000000),

('BB300001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'BB200001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 'B7000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB',
 1,
 1000000,
 1000000);


-- =====================================================
-- 14. GIAO DỊCH KHO KHI HOÀN THÀNH ĐƠN HÀNG
-- =====================================================

-- Đơn Completed bán 1 Samsung Galaxy S24
-- Tồn kho từ 20 giảm còn 19

INSERT INTO inventory_transactions
(transaction_id, branch_id, sku_id, transaction_type, quantity, reference_id)
VALUES
('AA400001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'A7000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA',
 'OUT',
 -1,
 'AA200004-AAAA-AAAA-AAAA-AAAAAAAAAAAA');


-- =====================================================
-- HOÀN TẤT
-- =====================================================

PRINT N'Seed data inserted successfully.';