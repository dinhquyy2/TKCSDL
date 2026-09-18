-- =====================================================================
-- OISM - SEED DATA (SQL Server) - phiên bản hợp nhất
-- Kế thừa ý tưởng 3 Tenant (ABC/XYZ/DEF) của TV2, viết lại khớp đúng
-- schema.sql 20 bảng của TV1. Thay thế cả data.sql và seed_data.sql cũ
-- (2 file trùng lặp) — đây là file seed duy nhất cần dùng.
-- =====================================================================

-- =====================================================================
-- 1. TENANTS (3 Tenant độc lập — phục vụ test cô lập dữ liệu đa Tenant)
-- =====================================================================
INSERT INTO tenants (tenant_id, name, domain, status) VALUES
('AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', N'Cửa hàng ABC', 'abc.vn', 'ACTIVE'),
('BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB', N'Cửa hàng XYZ', 'xyz.vn', 'ACTIVE'),
('CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC', N'Cửa hàng DEF', 'def.vn', 'ACTIVE');

-- =====================================================================
-- 2. BRANCHES
-- =====================================================================
INSERT INTO branches (branch_id, tenant_id, name, address, phone) VALUES
('A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', N'Chi nhánh Quận 1', N'123 Nguyễn Huệ, Quận 1, TP.HCM', '0901000001'),
('A1000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', N'Chi nhánh Quận 3', N'456 Võ Văn Tần, Quận 3, TP.HCM', '0901000002'),
('B1000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB','BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB', N'Chi nhánh Trung tâm', N'789 Lê Lợi, Quận 1, TP.HCM', '0902000001'),
('C1000001-CCCC-CCCC-CCCC-CCCCCCCCCCCC','CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC', N'Chi nhánh DEF', N'12 Cách Mạng Tháng 8, Quận 10, TP.HCM', '0903000001');

-- =====================================================================
-- 3. USERS (đủ 3 role/Tenant, đúng CHECK 'Owner','Staff','Cashier')
-- =====================================================================
INSERT INTO users (user_id, tenant_id, username, email, password_hash, role) VALUES
('A2000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','admin_abc','admin@abc.vn','demo_password_hash','Owner'),
('A2000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','staff_abc','staff@abc.vn','demo_password_hash','Staff'),
('A2000003-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','cashier_abc','cashier@abc.vn','demo_password_hash','Cashier'),
('B2000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB','BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB','admin_xyz','admin@xyz.vn','demo_password_hash','Owner'),
('C2000001-CCCC-CCCC-CCCC-CCCCCCCCCCCC','CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC','admin_def','admin@def.vn','demo_password_hash','Owner');

-- =====================================================================
-- 4. SALES CHANNELS (bắt buộc — orders.channel_id NOT NULL)
-- =====================================================================
INSERT INTO sales_channels (channel_id, tenant_id, code, name, type) VALUES
('D1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','POS', N'Bán tại quầy', 'OFFLINE'),
('D1000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','SHOPEE', N'Shopee', 'ONLINE'),
('D1000003-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','TIKTOK', N'TikTok Shop', 'ONLINE'),
('D2000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB','BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB','POS', N'Bán tại quầy', 'OFFLINE');

-- =====================================================================
-- 5. PARTNERS (Nhà cung cấp + Khách hàng)
-- =====================================================================
INSERT INTO partners (partner_id, tenant_id, name, type, phone, email) VALUES
('E1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', N'Nhà cung cấp ABC', 'SUPPLIER', '0909000001', 'supplier@abc.vn'),
('E1000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', N'Khách lẻ Nguyễn Văn Minh', 'CUSTOMER', '0909000002', 'minh@example.com'),
('E2000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB','BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB', N'Nhà cung cấp XYZ', 'SUPPLIER', '0909000003', 'supplier@xyz.vn');

-- =====================================================================
-- 6. PRODUCT CATEGORIES & BRANDS
-- =====================================================================
INSERT INTO product_categories (category_id, tenant_id, name) VALUES
('F1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', N'Điện thoại'),
('F1000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', N'Phụ kiện'),
('F2000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB','BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB', N'Laptop');

INSERT INTO brands (brand_id, tenant_id, name) VALUES
('10000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','Samsung'),
('10000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','Apple'),
('10000003-BBBB-BBBB-BBBB-BBBBBBBBBBBB','BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB','Dell');

-- =====================================================================
-- 7. PRODUCTS (đã có brand_id — hết mồ côi bảng brands)
-- =====================================================================
INSERT INTO products (product_id, tenant_id, category_id, brand_id, name, base_price) VALUES
('20000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','F1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','10000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', N'Samsung Galaxy A55', 8990000),
('20000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','F1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','10000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA', N'iPhone 15', 18990000),
('20000003-BBBB-BBBB-BBBB-BBBBBBBBBBBB','BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB','F2000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB','10000003-BBBB-BBBB-BBBB-BBBBBBBBBBBB', N'Dell Inspiron 15', 15990000);

-- =====================================================================
-- 8. SKU VARIANTS (đã có tenant_id, sku_code unique theo Tenant)
-- =====================================================================
INSERT INTO sku_variants (sku_id, tenant_id, product_id, sku_code, color, size, price) VALUES
('30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','20000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','SAM-A55-BLK', N'Đen', '128GB', 8990000),
('30000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','20000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA','IP15-BLK', N'Đen', '128GB', 18990000),
('30000003-BBBB-BBBB-BBBB-BBBBBBBBBBBB','BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB','20000003-BBBB-BBBB-BBBB-BBBBBBBBBBBB','DELL-I15-SLV', N'Bạc', '15-inch', 15990000);

-- =====================================================================
-- 9. BARCODES (unique toàn hệ thống, không giới hạn theo Tenant)
-- =====================================================================
INSERT INTO barcodes (barcode_id, tenant_id, sku_id, code) VALUES
('40000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','893000000001'),
('40000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA','AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','30000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA','893000000002'),
('40000003-BBBB-BBBB-BBBB-BBBBBBBBBBBB','BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB','30000003-BBBB-BBBB-BBBB-BBBBBBBBBBBB','893000000003');

-- =====================================================================
-- 10. KỊCH BẢN NHẬP HÀNG 2 ĐỢT — kiểm chứng công thức WAC thật
--     (100 đơn vị giá 7.000.000đ, sau đó 50 đơn vị giá 8.000.000đ)
--     avg_cost ky vong = (100*7000000 + 50*8000000) / 150 = 7333333.33
-- =====================================================================
DECLARE @Receipt1 UNIQUEIDENTIFIER = NEWID();
INSERT INTO purchase_receipts (receipt_id, tenant_id, branch_id, partner_id, status, total_amount)
VALUES (@Receipt1, 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'E1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'Confirmed', 700000000);

INSERT INTO purchase_receipt_items (receipt_item_id, tenant_id, receipt_id, sku_id, quantity, cost_price)
VALUES (NEWID(), 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', @Receipt1, '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 100, 7000000);

INSERT INTO inventory_transactions (transaction_id, tenant_id, branch_id, sku_id, transaction_type, quantity, balance_after, reference_id, reference_type)
VALUES (NEWID(), 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'IN', 100, 100, @Receipt1, 'PURCHASE_RECEIPT');

INSERT INTO stock_balances (tenant_id, branch_id, sku_id, on_hand, reserved, avg_cost)
VALUES ('AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 100, 0, 7000000);

DECLARE @Receipt2 UNIQUEIDENTIFIER = NEWID();
INSERT INTO purchase_receipts (receipt_id, tenant_id, branch_id, partner_id, status, total_amount)
VALUES (@Receipt2, 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'E1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'Confirmed', 400000000);

INSERT INTO purchase_receipt_items (receipt_item_id, tenant_id, receipt_id, sku_id, quantity, cost_price)
VALUES (NEWID(), 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', @Receipt2, '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 50, 8000000);

INSERT INTO inventory_transactions (transaction_id, tenant_id, branch_id, sku_id, transaction_type, quantity, balance_after, reference_id, reference_type)
VALUES (NEWID(), 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'IN', 50, 150, @Receipt2, 'PURCHASE_RECEIPT');

UPDATE stock_balances
SET on_hand = 150, avg_cost = 7333333.33, updated_at = GETDATE()
WHERE branch_id = 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA' AND sku_id = '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA';

-- Tồn kho khởi tạo cho 2 SKU còn lại (không qua kịch bản 2 đợt)
INSERT INTO stock_balances (tenant_id, branch_id, sku_id, on_hand, reserved, avg_cost) VALUES
('AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','30000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 10, 0, 15000000),
('BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB','B1000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB','30000003-BBBB-BBBB-BBBB-BBBBBBBBBBBB', 15, 0, 13000000);

INSERT INTO inventory_transactions (transaction_id, tenant_id, branch_id, sku_id, transaction_type, quantity, balance_after, reference_type) VALUES
(NEWID(),'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA','A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA','30000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA','IN', 10, 10, NULL),
(NEWID(),'BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB','B1000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB','30000003-BBBB-BBBB-BBBB-BBBBBBBBBBBB','IN', 15, 15, NULL);

-- =====================================================================
-- 11. ĐƠN HÀNG MẪU — đủ 5 trạng thái, đủ nhiều kênh (Omnichannel)
-- =====================================================================
DECLARE @Order1 UNIQUEIDENTIFIER = NEWID(); -- Draft, kênh POS
INSERT INTO orders (order_id, tenant_id, branch_id, channel_id, partner_id, user_id, status, total_amount)
VALUES (@Order1, 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'D1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'E1000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A2000003-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'Draft', 8990000);
INSERT INTO order_items (order_item_id, tenant_id, order_id, sku_id, quantity, unit_price, cost_price)
VALUES (NEWID(), 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', @Order1, '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 1, 8990000, 7333333.33);

DECLARE @Order2 UNIQUEIDENTIFIER = NEWID(); -- Reserved, kênh Shopee (Omnichannel)
INSERT INTO orders (order_id, tenant_id, branch_id, channel_id, partner_id, user_id, status, total_amount)
VALUES (@Order2, 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'D1000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'E1000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A2000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'Reserved', 18990000);
INSERT INTO order_items (order_item_id, tenant_id, order_id, sku_id, quantity, unit_price, cost_price)
VALUES (NEWID(), 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', @Order2, '30000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 1, 18990000, 15000000);
UPDATE stock_balances SET reserved = reserved + 1 WHERE branch_id='A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA' AND sku_id='30000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA';

DECLARE @Order3 UNIQUEIDENTIFIER = NEWID(); -- Confirmed, kênh POS, đã trừ kho thật
INSERT INTO orders (order_id, tenant_id, branch_id, channel_id, partner_id, user_id, status, total_amount)
VALUES (@Order3, 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'D1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'E1000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A2000003-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'Confirmed', 7333333.33 * 2);
INSERT INTO order_items (order_item_id, tenant_id, order_id, sku_id, quantity, unit_price, cost_price)
VALUES (NEWID(), 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', @Order3, '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 2, 7333333.33, 7333333.33);
INSERT INTO inventory_transactions (transaction_id, tenant_id, branch_id, sku_id, transaction_type, quantity, balance_after, reference_id, reference_type)
VALUES (NEWID(), 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'OUT', 2, 148, @Order3, 'ORDER');
UPDATE stock_balances SET on_hand = 148 WHERE branch_id='A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA' AND sku_id='30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA';

DECLARE @Order4 UNIQUEIDENTIFIER = NEWID(); -- Completed
INSERT INTO orders (order_id, tenant_id, branch_id, channel_id, partner_id, user_id, status, total_amount)
VALUES (@Order4, 'BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB', 'B1000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB', 'D2000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB', NULL, 'B2000001-BBBB-BBBB-BBBB-BBBBBBBBBBBB', 'Completed', 15990000);
INSERT INTO order_items (order_item_id, tenant_id, order_id, sku_id, quantity, unit_price, cost_price)
VALUES (NEWID(), 'BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB', @Order4, '30000003-BBBB-BBBB-BBBB-BBBBBBBBBBBB', 1, 15990000, 13000000);

DECLARE @Order5 UNIQUEIDENTIFIER = NEWID(); -- Cancelled, kênh TikTok
INSERT INTO orders (order_id, tenant_id, branch_id, channel_id, partner_id, user_id, status, total_amount)
VALUES (@Order5, 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'D1000003-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'E1000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A2000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'Cancelled', 18990000);
INSERT INTO order_items (order_item_id, tenant_id, order_id, sku_id, quantity, unit_price, cost_price)
VALUES (NEWID(), 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', @Order5, '30000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 1, 18990000, 15000000);

-- =====================================================================
-- 12. CHUYỂN KHO MẪU (FR-INV-03) — trạng thái InTransit (chưa Completed)
-- =====================================================================
DECLARE @Transfer1 UNIQUEIDENTIFIER = NEWID();
INSERT INTO stock_transfers (transfer_id, tenant_id, from_branch_id, to_branch_id, status)
VALUES (@Transfer1, 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000002-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'InTransit');
INSERT INTO stock_transfer_items (transfer_item_id, tenant_id, transfer_id, sku_id, quantity)
VALUES (NEWID(), 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', @Transfer1, '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 20);
INSERT INTO inventory_transactions (transaction_id, tenant_id, branch_id, sku_id, transaction_type, quantity, balance_after, reference_id, reference_type)
VALUES (NEWID(), 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'OUT', 20, 128, @Transfer1, 'STOCK_TRANSFER');
UPDATE stock_balances SET on_hand = 128 WHERE branch_id='A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA' AND sku_id='30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA';

-- =====================================================================
-- 13. KIỂM KHO MẪU (FR-INV-04) — bảng bị bỏ sót ở bản v1.0
-- =====================================================================
DECLARE @Stocktake1 UNIQUEIDENTIFIER = NEWID();
INSERT INTO stocktakes (stocktake_id, tenant_id, branch_id, status)
VALUES (@Stocktake1, 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 'InProgress');
INSERT INTO stocktake_items (stocktake_item_id, tenant_id, stocktake_id, sku_id, counted_qty, system_qty)
VALUES (NEWID(), 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', @Stocktake1, '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA', 126,
        (SELECT on_hand FROM stock_balances WHERE branch_id='A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA' AND sku_id='30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA'));
-- variance_qty tự tính = 126 - 128 = -2 (computed column, không cần INSERT)
