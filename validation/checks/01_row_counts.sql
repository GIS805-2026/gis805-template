-- ============================================================
-- 01_row_counts.sql - Verify plausible data volumes
-- Run: duckdb db/nexamart.duckdb < validation/checks/01_row_counts.sql
-- ============================================================

SELECT '=== ROW COUNT CHECKS ===' as check_category;

-- Raw table row counts
SELECT
    'raw_customers' as table_name,
    COUNT(*) as row_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL - Empty table' END as result
FROM raw_customers;

SELECT
    'raw_products' as table_name,
    COUNT(*) as row_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL - Empty table' END as result
FROM raw_products;

SELECT
    'raw_stores' as table_name,
    COUNT(*) as row_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL - Empty table' END as result
FROM raw_stores;

SELECT
    'raw_orders' as table_name,
    COUNT(*) as row_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL - Empty table' END as result
FROM raw_orders;

SELECT
    'raw_order_lines' as table_name,
    COUNT(*) as row_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL - Empty table' END as result
FROM raw_order_lines;

-- Check order_lines has more rows than orders (expected)
SELECT
    'lines_vs_orders_ratio' as check_name,
    ROUND(
        (SELECT COUNT(*) FROM raw_order_lines)::FLOAT /
        NULLIF((SELECT COUNT(*) FROM raw_orders), 0),
        2
    ) as ratio,
    CASE
        WHEN (SELECT COUNT(*) FROM raw_order_lines) > (SELECT COUNT(*) FROM raw_orders)
        THEN 'PASS - Lines > Orders as expected'
        ELSE 'WARNING - Check line item generation'
    END as result;
