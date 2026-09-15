-- 1. Kiem tra Ledger va StockBalance
SELECT
    sb.branch_id,
    sb.sku_id,
    sb.on_hand AS stock_balance_qty,
    COALESCE(
        SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                ELSE -it.quantity
            END
        ), 0
    ) AS ledger_qty,
    sb.on_hand -
    COALESCE(
        SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                ELSE -it.quantity
            END
        ), 0
    ) AS difference
FROM stock_balances sb
LEFT JOIN inventory_transactions it
    ON it.branch_id = sb.branch_id
    AND it.sku_id = sb.sku_id
GROUP BY sb.branch_id, sb.sku_id, sb.on_hand
ORDER BY sb.branch_id, sb.sku_id;


-- 2. Kiem tra tong tien don hang
SELECT
    o.order_id,
    o.status,
    o.total_amount,
    COALESCE(SUM(oi.subtotal), 0) AS item_total,
    o.total_amount - COALESCE(SUM(oi.subtotal), 0) AS difference
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.status, o.total_amount
ORDER BY o.status;


-- 3. Test cong thuc gia von binh quan
WITH test AS (
    SELECT
        20::numeric AS old_qty,
        7000000::numeric AS old_cost,
        10::numeric AS in_qty,
        8000000::numeric AS in_cost
)
SELECT ROUND(
    (old_qty * old_cost + in_qty * in_cost)
    / (old_qty + in_qty), 2
) AS weighted_avg_cost
FROM test;
