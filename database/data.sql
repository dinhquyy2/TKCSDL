

DECLARE @TenantID UNIQUEIDENTIFIER = '11111111-1111-1111-1111-111111111111';

-- 1. TENANT
INSERT INTO tenants (tenant_id, name, domain, status)
VALUES (@TenantID, N'OISM Retail System', 'oism.vn', 'ACTIVE');

-- 2. CHI NHANH
DECLARE @BranchHCM UNIQUEIDENTIFIER = '22222222-1111-1111-1111-111111111111';
DECLARE @BranchHN  UNIQUEIDENTIFIER = '22222222-2222-2222-2222-222222222222';
INSERT INTO branches (branch_id, tenant_id, name, address, phone)
VALUES
(@BranchHCM, @TenantID, N'Chi nhánh Hồ Chí Minh', N'Quận 1, TP.HCM', '0901234567'),
(@BranchHN,  @TenantID, N'Chi nhánh Hà Nội', N'Đống Đa, Hà Nội', '0907654321');

-- 3. KÊNH BÁN (moi - bat buoc vi orders.channel_id NOT NULL)
DECLARE @ChannelPOS UNIQUEIDENTIFIER = NEWID();
DECLARE @ChannelShopee UNIQUEIDENTIFIER = NEWID();
INSERT INTO sales_channels (channel_id, tenant_id, code, name, type)
VALUES
(@ChannelPOS, @TenantID, 'POS', N'Bán tại quầy', 'OFFLINE'),
(@ChannelShopee, @TenantID, 'SHOPEE', N'Shopee', 'ONLINE');

-- 4. NGƯỜI DÙNG
DECLARE @UserAdmin UNIQUEIDENTIFIER = '33333333-1111-1111-1111-111111111111';
INSERT INTO users (user_id, tenant_id, username, email, password_hash, full_name, role)
VALUES
(@UserAdmin, @TenantID, 'admin', 'admin@oism.vn', 'hashed_pwd_123', N'Nguyễn Văn Admin', 'Owner'),
('33333333-2222-2222-2222-222222222222', @TenantID, 'manager_hcm', 'manager@oism.vn', 'hashed_pwd_456', N'Trần Quản Lý', 'Staff');

-- 5. ĐỐI TÁC
DECLARE @PartnerSupplier UNIQUEIDENTIFIER = '44444444-1111-1111-1111-111111111111';
DECLARE @PartnerCustomer UNIQUEIDENTIFIER = '44444444-2222-2222-2222-222222222222';
INSERT INTO partners (partner_id, tenant_id, type, name, phone)
VALUES
(@PartnerSupplier, @TenantID, 'SUPPLIER', N'Công ty TNHH May Mặc VN', '0988776655'),
(@PartnerCustomer, @TenantID, 'CUSTOMER', N'Khách lẻ - Lê Tuấn', '0912345678');

-- 6. DANH MỤC & THƯƠNG HIỆU
DECLARE @CategoryAoThun UNIQUEIDENTIFIER = '55555555-1111-1111-1111-111111111111';
INSERT INTO product_categories (category_id, tenant_id, name)
VALUES (@CategoryAoThun, @TenantID, N'Áo thun');

DECLARE @BrandOISM UNIQUEIDENTIFIER = '66666666-1111-1111-1111-111111111111';
INSERT INTO brands (brand_id, tenant_id, name)
VALUES (@BrandOISM, @TenantID, 'OISM Basic');

-- 7. SẢN PHẨM (nay co brand_id - da sua loi bang mo coi)
DECLARE @ProductAoThun UNIQUEIDENTIFIER = '77777777-1111-1111-1111-111111111111';
INSERT INTO products (product_id, tenant_id, category_id, brand_id, name, base_price)
VALUES (@ProductAoThun, @TenantID, @CategoryAoThun, @BrandOISM, N'Áo thun OISM Cổ Tròn', 250000);

-- 8. BIẾN THỂ SẢN PHẨM (nay co tenant_id)
DECLARE @SkuTshirtWhite UNIQUEIDENTIFIER = '88888888-1111-1111-1111-111111111111';
INSERT INTO sku_variants (sku_id, tenant_id, product_id, sku_code, color, size, price)
VALUES (@SkuTshirtWhite, @TenantID, @ProductAoThun, 'TSHIRT-WHT-M', N'Trắng', 'M', 250000);

-- 9. MÃ VẠCH (nay co tenant_id)
INSERT INTO barcodes (barcode_id, tenant_id, sku_id, code)
VALUES (NEWID(), @TenantID, @SkuTshirtWhite, '8938505970015');

-- =====================================================================
-- 10. KỊCH BẢN NHẬP HÀNG 2 ĐỢT - kiểm chứng công thức giá vốn bình quân
-- =====================================================================

-- Đợt 1: 100 đơn vị, giá 50.000đ
DECLARE @Receipt1 UNIQUEIDENTIFIER = NEWID();
INSERT INTO purchase_receipts (receipt_id, tenant_id, branch_id, partner_id, status, total_amount)
VALUES (@Receipt1, @TenantID, @BranchHCM, @PartnerSupplier, 'Confirmed', 5000000);

INSERT INTO purchase_receipt_items (receipt_item_id, tenant_id, receipt_id, sku_id, quantity, cost_price)
VALUES (NEWID(), @TenantID, @Receipt1, @SkuTshirtWhite, 100, 50000);

INSERT INTO inventory_transactions (transaction_id, tenant_id, branch_id, sku_id, transaction_type, quantity, balance_after, reference_id, reference_type)
VALUES (NEWID(), @TenantID, @BranchHCM, @SkuTshirtWhite, 'IN', 100, 100, @Receipt1, 'PURCHASE_RECEIPT');

-- Khoi tao dong stock_balances (lan dau) voi avg_cost = 50.000
INSERT INTO stock_balances (tenant_id, branch_id, sku_id, on_hand, reserved, avg_cost)
VALUES (@TenantID, @BranchHCM, @SkuTshirtWhite, 100, 0, 50000);

-- Đợt 2: 50 đơn vị, giá 56.000đ
-- avg_cost moi = (100*50000 + 50*56000) / 150 = 52.000
DECLARE @Receipt2 UNIQUEIDENTIFIER = NEWID();
INSERT INTO purchase_receipts (receipt_id, tenant_id, branch_id, partner_id, status, total_amount)
VALUES (@Receipt2, @TenantID, @BranchHCM, @PartnerSupplier, 'Confirmed', 2800000);

INSERT INTO purchase_receipt_items (receipt_item_id, tenant_id, receipt_id, sku_id, quantity, cost_price)
VALUES (NEWID(), @TenantID, @Receipt2, @SkuTshirtWhite, 50, 56000);

INSERT INTO inventory_transactions (transaction_id, tenant_id, branch_id, sku_id, transaction_type, quantity, balance_after, reference_id, reference_type)
VALUES (NEWID(), @TenantID, @BranchHCM, @SkuTshirtWhite, 'IN', 50, 150, @Receipt2, 'PURCHASE_RECEIPT');

UPDATE stock_balances
SET on_hand = 150, avg_cost = 52000, updated_at = GETDATE()
WHERE branch_id = @BranchHCM AND sku_id = @SkuTshirtWhite;

-- =====================================================================
-- 11. ĐƠN HÀNG MẪU (kênh POS, đủ vòng đời Draft -> Confirmed)
-- =====================================================================

DECLARE @OrderID1 UNIQUEIDENTIFIER = NEWID();
INSERT INTO orders (order_id, tenant_id, branch_id, channel_id, partner_id, user_id, status, total_amount)
VALUES (@OrderID1, @TenantID, @BranchHCM, @ChannelPOS, @PartnerCustomer, @UserAdmin, 'Confirmed', 500000);

-- cost_price = avg_cost hien tai (52.000) tai thoi diem Confirm - snapshot BR-04
INSERT INTO order_items (order_item_id, tenant_id, order_id, sku_id, quantity, unit_price, cost_price)
VALUES (NEWID(), @TenantID, @OrderID1, @SkuTshirtWhite, 2, 250000, 52000);

-- Ghi nhan xuat kho khi ban (Deduct): OnHand 150 -> 148, ghi Ledger OUT
INSERT INTO inventory_transactions (transaction_id, tenant_id, branch_id, sku_id, transaction_type, quantity, balance_after, reference_id, reference_type)
VALUES (NEWID(), @TenantID, @BranchHCM, @SkuTshirtWhite, 'OUT', 2, 148, @OrderID1, 'ORDER');

UPDATE stock_balances
SET on_hand = 148, updated_at = GETDATE()
WHERE branch_id = @BranchHCM AND sku_id = @SkuTshirtWhite;

-- =====================================================================
-- 12. CHUYỂN KHO MẪU (FR-INV-03) - trước đây chưa có dữ liệu minh họa
-- =====================================================================

DECLARE @Transfer1 UNIQUEIDENTIFIER = NEWID();
INSERT INTO stock_transfers (transfer_id, tenant_id, from_branch_id, to_branch_id, status)
VALUES (@Transfer1, @TenantID, @BranchHCM, @BranchHN, 'InTransit');

INSERT INTO stock_transfer_items (transfer_item_id, tenant_id, transfer_id, sku_id, quantity)
VALUES (NEWID(), @TenantID, @Transfer1, @SkuTshirtWhite, 20);

-- Buoc 1 (Outbound) - da xac nhan xuat tai chi nhanh nguon (HCM)
INSERT INTO inventory_transactions (transaction_id, tenant_id, branch_id, sku_id, transaction_type, quantity, balance_after, reference_id, reference_type)
VALUES (NEWID(), @TenantID, @BranchHCM, @SkuTshirtWhite, 'OUT', 20, 128, @Transfer1, 'STOCK_TRANSFER');

UPDATE stock_balances SET on_hand = 128, updated_at = GETDATE()
WHERE branch_id = @BranchHCM AND sku_id = @SkuTshirtWhite;

-- Buoc 2 (Inbound) - CHUA xac nhan nhap tai chi nhanh dich (HN) trong seed
-- nay -> minh hoa dung trang thai "InTransit" (chua Completed). Muon test
-- tiep buoc Inbound, chay rieng doan sau:
--
-- UPDATE stock_transfers SET status = 'Completed' WHERE transfer_id = @Transfer1;
-- INSERT INTO stock_balances (tenant_id, branch_id, sku_id, on_hand, reserved, avg_cost)
--     VALUES (@TenantID, @BranchHN, @SkuTshirtWhite, 20, 0, 52000);
-- INSERT INTO inventory_transactions (...) VALUES (..., 'IN', 20, 20, @Transfer1, 'STOCK_TRANSFER');

-- =====================================================================
-- 13. KIỂM KHO MẪU (FR-INV-04) - bảng bị bỏ sót hoàn toàn ở bản v1.0
-- =====================================================================

DECLARE @Stocktake1 UNIQUEIDENTIFIER = NEWID();
INSERT INTO stocktakes (stocktake_id, tenant_id, branch_id, status)
VALUES (@Stocktake1, @TenantID, @BranchHCM, 'InProgress');

-- Nhan vien dem thuc te duoc 126 (he thong dang ghi 128) -> lech 2 don vi
INSERT INTO stocktake_items (stocktake_item_id, tenant_id, stocktake_id, sku_id, counted_qty, system_qty)
VALUES (NEWID(), @TenantID, @Stocktake1, @SkuTshirtWhite, 126,
        (SELECT on_hand FROM stock_balances WHERE branch_id = @BranchHCM AND sku_id = @SkuTshirtWhite));
-- variance_qty se tu dong tinh = 126 - 128 = -2 (cot computed, khong can INSERT)

-- Sau khi hoan tat kiem kho, sinh but toan dieu chinh (Adjustment) vao Ledger
-- va dong stocktake (thao tac nay do ung dung thuc hien, minh hoa o day):
--
-- INSERT INTO inventory_transactions (..., transaction_type, quantity, ..., reference_type)
--     VALUES (..., 'OUT', 2, ..., 'STOCKTAKE_ADJUSTMENT');
-- UPDATE stock_balances SET on_hand = 126 WHERE branch_id = @BranchHCM AND sku_id = @SkuTshirtWhite;
-- UPDATE stocktakes SET status = 'Completed', completed_at = GETDATE() WHERE stocktake_id = @Stocktake1;

-- =====================================================================
-- 14. ĐƠN HÀNG KÊNH ONLINE MẪU - minh họa đúng tính "Omnichannel"
-- =====================================================================

DECLARE @OrderID2 UNIQUEIDENTIFIER = NEWID();
INSERT INTO orders (order_id, tenant_id, branch_id, channel_id, status, total_amount)
VALUES (@OrderID2, @TenantID, @BranchHCM, @ChannelShopee, 'Reserved', 250000);

INSERT INTO order_items (order_item_id, tenant_id, order_id, sku_id, quantity, unit_price, cost_price)
VALUES (NEWID(), @TenantID, @OrderID2, @SkuTshirtWhite, 1, 250000, 52000);

-- Don o trang thai Reserved: chi tang "reserved", CHUA tru "on_hand"
-- (dung theo dinh nghia FR-RSE-02 - xem PHYSICAL_DESIGN.md muc 3)
UPDATE stock_balances SET reserved = reserved + 1, updated_at = GETDATE()
WHERE branch_id = @BranchHCM AND sku_id = @SkuTshirtWhite;
