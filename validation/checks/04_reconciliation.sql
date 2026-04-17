-- ============================================================
-- 04_reconciliation.sql - Verify calculations reconcile
-- Run: duckdb db/nexamart.duckdb < validation/checks/04_reconciliation.sql
-- ============================================================

SELECT '=== RECONCILIATION CHECKS ===' as check_category;

-- Line total calculation check
SELECT
    'line_total_calc' as check_name,
    COUNT(*) as mismatched_rows,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'WARNING - Some line_totals may not match quantity * unit_price * (1 - discount)'
    END as result
FROM raw_order_lines
WHERE ABS(line_total - (quantity * unit_price * (1 - COALESCE(discount_pct, 0)))) > 0.01;

-- Order line count per order (sanity check)
SELECT
    'lines_per_order' as check_name,
    MIN(line_count) as min_lines,
    AVG(line_count)::DECIMAL(10,2) as avg_lines,
    MAX(line_count) as max_lines,
    CASE
        WHEN MIN(line_count) >= 1 THEN 'PASS'
        ELSE 'FAIL - Orders with zero lines'
    END as result
FROM (
    SELECT order_id, COUNT(*) as line_count
    FROM raw_order_lines
    GROUP BY order_id
);

-- Total revenue sanity check
SELECT
    'total_revenue_range' as check_name,
    SUM(line_total)::DECIMAL(15,2) as total_revenue,
    CASE
        WHEN SUM(line_total) > 0 THEN 'PASS'
        ELSE 'FAIL - Zero or negative total revenue'
    END as result
FROM raw_order_lines;

-- Date range sanity check
SELECT
    'order_date_range' as check_name,
    MIN(order_date) as min_date,
    MAX(order_date) as max_date,
    CASE
        WHEN MIN(order_date) < MAX(order_date) THEN 'PASS'
        ELSE 'WARNING - Check date range'
    END as result
FROM raw_orders;

-- Return rate sanity check
SELECT
    'return_rate' as check_name,
    COUNT(*) FILTER (WHERE order_status = 'returned') as returned_orders,
    COUNT(*) as total_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE order_status = 'returned') / NULLIF(COUNT(*), 0),
        2
    ) as return_rate_pct,
    CASE
        WHEN COUNT(*) FILTER (WHERE order_status = 'returned')::FLOAT / NULLIF(COUNT(*), 0) < 0.2
        THEN 'PASS - Return rate under 20%'
        ELSE 'WARNING - High return rate'
    END as result
FROM raw_orders;
