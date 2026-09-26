-- =====================================================================
-- OISM - INTEGRITY CHECK (BAN GON, 1 BANG DUY NHAT)
-- Muc tieu: thay vi 10+ khung ket qua roi rac, gop toan bo thanh
-- 1 bang tong hop duy nhat, de doc, de biet ngay cho nao PASS/FAIL.
-- Chay sau khi da co du: schema.sql + ledger_constraints.sql + seed_data.sql
-- =====================================================================

SELECT
    STT, TenKiemTra, SoLuongLoi,
    CASE WHEN SoLuongLoi = 0 THEN N'PASS' ELSE N'FAIL' END AS KetQua
FROM (
    -- 1. Subtotal cua OrderItem co dung khong
    SELECT 1 AS STT, N'Subtotal OrderItem dung cong thuc' AS TenKiemTra,
           COUNT(*) AS SoLuongLoi
    FROM order_items
    WHERE subtotal <> quantity * unit_price

    UNION ALL
    -- 2. Co lap Tenant: orders vs branches
    SELECT 2, N'Co lap Tenant - Orders/Branches',
           COUNT(*)
    FROM orders o JOIN branches b ON o.branch_id = b.branch_id
    WHERE o.tenant_id <> b.tenant_id

    UNION ALL
    -- 3. Co lap Tenant: stock_balances vs sku_variants
    SELECT 3, N'Co lap Tenant - StockBalance/SKU',
           COUNT(*)
    FROM stock_balances sb JOIN sku_variants sv ON sb.sku_id = sv.sku_id
    WHERE sb.tenant_id <> sv.tenant_id

    UNION ALL
    -- 4. Co lap Tenant: inventory_transactions vs branches
    SELECT 4, N'Co lap Tenant - Ledger/Branches',
           COUNT(*)
    FROM inventory_transactions it JOIN branches br ON it.branch_id = br.branch_id
    WHERE it.tenant_id <> br.tenant_id

    UNION ALL
    -- 5. Co lap Tenant: order_items vs orders
    SELECT 5, N'Co lap Tenant - OrderItems/Orders',
           COUNT(*)
    FROM order_items oi JOIN orders o ON oi.order_id = o.order_id
    WHERE oi.tenant_id <> o.tenant_id

    UNION ALL
    -- 6. Ton kho khong duoc am
    SELECT 6, N'Ton kho khong am (on_hand/reserved/available)',
           COUNT(*)
    FROM stock_balances
    WHERE on_hand < 0 OR reserved < 0 OR available < 0

    UNION ALL
    -- 7. SKU mo coi (khong co Product)
    SELECT 7, N'Khong co SKU mo coi',
           COUNT(*)
    FROM sku_variants
    WHERE product_id IS NULL

    UNION ALL
    -- 8. OrderItem mo coi (khong co Order)
    SELECT 8, N'Khong co OrderItem mo coi',
           COUNT(*)
    FROM order_items oi
    LEFT JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_id IS NULL

    UNION ALL
    -- 9. Doi chieu Ledger <-> StockBalance
    SELECT 9, N'Ledger khop StockBalance (on_hand)',
           COUNT(*)
    FROM (
        SELECT sb.branch_id, sb.sku_id, sb.on_hand,
               SUM(CASE WHEN it.transaction_type = 'IN' THEN it.quantity ELSE -it.quantity END) AS tong_ledger
        FROM stock_balances sb
        JOIN inventory_transactions it ON it.sku_id = sb.sku_id AND it.branch_id = sb.branch_id
        GROUP BY sb.branch_id, sb.sku_id, sb.on_hand
        HAVING sb.on_hand <> SUM(CASE WHEN it.transaction_type = 'IN' THEN it.quantity ELSE -it.quantity END)
    ) x

    UNION ALL
    -- 10. Doi chieu Orders.total_amount
    SELECT 10, N'Orders.total_amount khop SUM(subtotal)',
           COUNT(*)
    FROM (
        SELECT o.order_id
        FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
        GROUP BY o.order_id, o.total_amount
        HAVING o.total_amount <> SUM(oi.subtotal)
    ) y
) AS TongHop
ORDER BY STT;
