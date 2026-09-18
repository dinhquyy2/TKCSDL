-- =====================================================================
-- OISM - INTEGRITY CHECK (SQL Server) - phiên bản hợp nhất, đủ 8 phần
-- Kế thừa các check hay của TV2 (mục 1,2,3,6,7), bổ sung 2 phần thiếu
-- (mục 4: append-only, mục 5: cô lập Tenant), sửa lại mục 8 (WAC) để
-- test trên dữ liệu thật thay vì số bịa tay.
-- Cách dùng: chạy sau khi đã nạp schema.sql + ledger_constraints.sql +
--            seed_data.sql. Mọi truy vấn "kỳ vọng 0 dòng" là ĐÚNG khi
--            không trả về dòng nào.
-- =====================================================================

PRINT N'===== BẮT ĐẦU KIỂM TRA TOÀN VẸN DỮ LIỆU =====';

-- =====================================================================
-- 1. Số lượng dữ liệu chính (sanity check nhanh)
-- =====================================================================
PRINT N'--- 1. Số lượng dữ liệu chính ---';
SELECT 'Tenants' AS TableName, COUNT(*) AS TotalRows FROM tenants
UNION ALL SELECT 'Users', COUNT(*) FROM users
UNION ALL SELECT 'Branches', COUNT(*) FROM branches
UNION ALL SELECT 'SalesChannels', COUNT(*) FROM sales_channels
UNION ALL SELECT 'Products', COUNT(*) FROM products
UNION ALL SELECT 'SKUVariants', COUNT(*) FROM sku_variants
UNION ALL SELECT 'Orders', COUNT(*) FROM orders
UNION ALL SELECT 'OrderItems', COUNT(*) FROM order_items
UNION ALL SELECT 'Stocktakes', COUNT(*) FROM stocktakes
UNION ALL SELECT 'StockTransfers', COUNT(*) FROM stock_transfers;

-- =====================================================================
-- 2. Đơn hàng có đủ 5 trạng thái state machine không
-- =====================================================================
PRINT N'--- 2. Phân bố trạng thái Order ---';
SELECT status, COUNT(*) AS TotalOrders
FROM orders GROUP BY status ORDER BY status;
-- Ky vong: co du 5 dong (Draft, Reserved, Confirmed, Completed, Cancelled)

-- =====================================================================
-- 3. order_items.subtotal (computed) có khớp quantity*unit_price không
-- =====================================================================
PRINT N'--- 3. Kiểm tra subtotal của OrderItem ---';
SELECT order_item_id, quantity, unit_price, subtotal,
       quantity * unit_price AS CalculatedSubtotal
FROM order_items
WHERE subtotal <> quantity * unit_price;
-- Ky vong: 0 dong (vi subtotal la computed column, khong the sai)

-- =====================================================================
-- 4. Kiểm chứng ràng buộc APPEND-ONLY (thiếu ở bản gốc — bổ sung mới)
-- =====================================================================
PRINT N'--- 4. Kiểm chứng ràng buộc Append-only (Ledger) ---';
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @test_txn_id UNIQUEIDENTIFIER;
    SELECT TOP 1 @test_txn_id = transaction_id FROM inventory_transactions;

    UPDATE inventory_transactions SET quantity = 999 WHERE transaction_id = @test_txn_id;

    PRINT N'[FAIL] UPDATE tren inventory_transactions THANH CONG -> trigger append-only KHONG hoat dong';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'[PASS] UPDATE bi chan dung nhu ky vong: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @test_txn_id2 UNIQUEIDENTIFIER;
    SELECT TOP 1 @test_txn_id2 = transaction_id FROM inventory_transactions;

    DELETE FROM inventory_transactions WHERE transaction_id = @test_txn_id2;

    PRINT N'[FAIL] DELETE tren inventory_transactions THANH CONG -> trigger append-only KHONG hoat dong';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'[PASS] DELETE bi chan dung nhu ky vong: ' + ERROR_MESSAGE();
END CATCH;

-- =====================================================================
-- 5. Kiểm chứng CÔ LẬP DỮ LIỆU ĐA TENANT (thiếu ở bản gốc — bổ sung mới)
-- =====================================================================
PRINT N'--- 5. Kiểm chứng cô lập dữ liệu đa Tenant ---';

SELECT o.order_id, o.tenant_id AS order_tenant, b.tenant_id AS branch_tenant
FROM orders o JOIN branches b ON o.branch_id = b.branch_id
WHERE o.tenant_id <> b.tenant_id;
-- Ky vong: 0 dong

SELECT sb.branch_id, sb.sku_id, sb.tenant_id AS balance_tenant, sv.tenant_id AS sku_tenant
FROM stock_balances sb JOIN sku_variants sv ON sb.sku_id = sv.sku_id
WHERE sb.tenant_id <> sv.tenant_id;
-- Ky vong: 0 dong

SELECT it.transaction_id, it.tenant_id AS ledger_tenant, br.tenant_id AS branch_tenant
FROM inventory_transactions it JOIN branches br ON it.branch_id = br.branch_id
WHERE it.tenant_id <> br.tenant_id;
-- Ky vong: 0 dong

SELECT oi.order_item_id, oi.tenant_id AS item_tenant, o.tenant_id AS order_tenant
FROM order_items oi JOIN orders o ON oi.order_id = o.order_id
WHERE oi.tenant_id <> o.tenant_id;
-- Ky vong: 0 dong

-- =====================================================================
-- 6. Kiểm tra tồn kho không bị âm (bên cạnh CHECK constraint đã có)
-- =====================================================================
PRINT N'--- 6. Kiểm tra tồn kho không âm ---';
SELECT branch_id, sku_id, on_hand, reserved, available
FROM stock_balances
WHERE on_hand < 0 OR reserved < 0 OR available < 0;
-- Ky vong: 0 dong

-- =====================================================================
-- 7. Kiểm tra dữ liệu mồ côi (orphan) — SKU không có Product, OrderItem
--    không có Order
-- =====================================================================
PRINT N'--- 7. Kiểm tra dữ liệu mồ côi ---';
SELECT sku_id, product_id, sku_code
FROM sku_variants WHERE product_id IS NULL;
-- Ky vong: 0 dong

SELECT oi.order_item_id, oi.order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
-- Ky vong: 0 dong

-- =====================================================================
-- 8. Đối chiếu tổng Ledger với StockBalance
-- =====================================================================
PRINT N'--- 8. Đối chiếu Ledger <-> StockBalance ---';
SELECT
    sb.branch_id, sb.sku_id, sb.on_hand AS balance_on_hand,
    SUM(CASE WHEN it.transaction_type = 'IN' THEN it.quantity ELSE -it.quantity END) AS ledger_computed_on_hand
FROM stock_balances sb
JOIN inventory_transactions it ON it.sku_id = sb.sku_id AND it.branch_id = sb.branch_id
GROUP BY sb.branch_id, sb.sku_id, sb.on_hand
HAVING sb.on_hand <> SUM(CASE WHEN it.transaction_type = 'IN' THEN it.quantity ELSE -it.quantity END);
-- Ky vong: 0 dong

-- =====================================================================
-- 9. Đối chiếu Orders.total_amount với SUM(order_items.subtotal)
-- =====================================================================
PRINT N'--- 9. Đối chiếu Orders.total_amount ---';
SELECT o.order_id, o.status, o.total_amount, SUM(oi.subtotal) AS item_total,
       o.total_amount - SUM(oi.subtotal) AS difference
FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.status, o.total_amount
HAVING o.total_amount <> SUM(oi.subtotal);
-- Ky vong: 0 dong

-- =====================================================================
-- 10. Kiểm chứng công thức giá vốn bình quân TRÊN DỮ LIỆU THẬT
--     (bản gốc dùng số bịa tay DECLARE @TonCu=10... — đã sửa lại
--     để đọc trực tiếp từ purchase_receipt_items + stock_balances)
-- =====================================================================
PRINT N'--- 10. Kiểm chứng công thức giá vốn bình quân (dữ liệu thật) ---';

-- 10a. Tinh tay tu lich su nhap hang thuc te (SKU I1000001, da nhap 2 dot)
SELECT
    sku_id,
    SUM(quantity) AS total_qty_nhap,
    SUM(quantity * cost_price) / SUM(quantity) AS avg_cost_tinh_tu_receipt
FROM purchase_receipt_items
WHERE sku_id = '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA'
GROUP BY sku_id;

-- 10b. Doi chieu voi avg_cost dang luu trong stock_balances
SELECT branch_id, sku_id, avg_cost AS avg_cost_luu_trong_he_thong
FROM stock_balances
WHERE branch_id = 'A1000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA'
  AND sku_id = '30000001-AAAA-AAAA-AAAA-AAAAAAAAAAAA';
-- Ky vong: avg_cost_luu_trong_he_thong ~ avg_cost_tinh_tu_receipt (~7333333.33)
-- Chi lech nho do sai so lam tron thap phan, KHONG duoc lech ban chat

PRINT N'===== KẾT THÚC KIỂM TRA TOÀN VẸN DỮ LIỆU =====';
PRINT N'Xem output tung muc o tren -- neu tat ca deu 0 dong / [PASS] la dat yeu cau.';
