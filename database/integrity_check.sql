-- =====================================================
-- INTEGRITY CHECK - SQL SERVER
-- Kiểm tra tính toàn vẹn dữ liệu
-- =====================================================

-- 1. Kiểm tra số lượng dữ liệu chính
SELECT 'Tenants' AS TableName, COUNT(*) AS TotalRows FROM tenants
UNION ALL
SELECT 'Users', COUNT(*) FROM users
UNION ALL
SELECT 'Branches', COUNT(*) FROM branches
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'SKU Variants', COUNT(*) FROM sku_variants
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Order Items', COUNT(*) FROM order_items;

-- 2. Kiểm tra Order có đủ 5 trạng thái
SELECT status, COUNT(*) AS TotalOrders
FROM orders
GROUP BY status
ORDER BY status;

-- 3. Kiểm tra Order Items
-- subtotal phải bằng quantity * unit_price
SELECT
    order_item_id,
    quantity,
    unit_price,
    subtotal,
    quantity * unit_price AS CalculatedSubtotal
FROM order_items
WHERE subtotal <> quantity * unit_price;

-- 4. Kiểm tra tồn kho không bị âm
SELECT
    branch_id,
    sku_id,
    quantity
FROM stock_balances
WHERE quantity < 0;

-- 5. Kiểm tra Inventory Ledger
-- Tổng số lượng giao dịch phải khớp với Stock Balance
SELECT
    sb.branch_id,
    sb.sku_id,
    sb.quantity AS StockBalance,
    ISNULL(SUM(it.quantity), 0) AS LedgerQuantity,
    sb.quantity - ISNULL(SUM(it.quantity), 0) AS Difference
FROM stock_balances sb
LEFT JOIN inventory_transactions it
    ON sb.branch_id = it.branch_id
    AND sb.sku_id = it.sku_id
GROUP BY
    sb.branch_id,
    sb.sku_id,
    sb.quantity;

-- 6. Kiểm tra dữ liệu SKU không có Product
SELECT
    sku_id,
    product_id,
    sku_code
FROM sku_variants
WHERE product_id IS NULL;

-- 7. Kiểm tra Order Item không có Order
SELECT
    oi.order_item_id,
    oi.order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 8. Kiểm tra công thức giá vốn bình quân gia quyền
-- Công thức:
-- GiaVonBQ = (TonCu * GiaCu + NhapMoi * GiaNhap) / (TonCu + NhapMoi)

DECLARE @TonCu DECIMAL(15,2) = 10;
DECLARE @GiaCu DECIMAL(15,2) = 7000000;
DECLARE @NhapMoi DECIMAL(15,2) = 5;
DECLARE @GiaNhap DECIMAL(15,2) = 8000000;

DECLARE @GiaVonBQ DECIMAL(15,2);

SET @GiaVonBQ =
    (@TonCu * @GiaCu + @NhapMoi * @GiaNhap)
    / (@TonCu + @NhapMoi);

SELECT
    @TonCu AS TonCu,
    @GiaCu AS GiaCu,
    @NhapMoi AS NhapMoi,
    @GiaNhap AS GiaNhap,
    @GiaVonBQ AS GiaVonBinhQuan;

PRINT N'Integrity check completed.';
