-- ============================================================
-- 03_null_policy.sql - Verify null handling follows policy
-- Run: duckdb db/nexamart.duckdb < validation/checks/03_null_policy.sql
-- ============================================================

SELECT '=== NULL POLICY CHECKS ===' as check_category;

-- Primary keys should never be null
SELECT
    'customer_id_not_null' as check_name,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) as null_count,
    CASE
        WHEN SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) = 0 THEN 'PASS'
        ELSE 'FAIL - Null customer_ids found'
    END as result
FROM raw_customers;

SELECT
    'product_id_not_null' as check_name,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) as null_count,
    CASE
        WHEN SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) = 0 THEN 'PASS'
        ELSE 'FAIL - Null product_ids found'
    END as result
FROM raw_products;

SELECT
    'order_id_not_null' as check_name,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) as null_count,
    CASE
        WHEN SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) = 0 THEN 'PASS'
        ELSE 'FAIL - Null order_ids found'
    END as result
FROM raw_orders;

-- Foreign keys in facts should not be null
SELECT
    'order_customer_fk_not_null' as check_name,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) as null_count,
    CASE
        WHEN SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) = 0 THEN 'PASS'
        ELSE 'WARNING - Null customer_ids in orders (may need unknown member)'
    END as result
FROM raw_orders;

SELECT
    'order_line_product_fk_not_null' as check_name,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) as null_count,
    CASE
        WHEN SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) = 0 THEN 'PASS'
        ELSE 'WARNING - Null product_ids in order_lines (may need unknown member)'
    END as result
FROM raw_order_lines;

-- Measures should not be null
SELECT
    'line_total_not_null' as check_name,
    SUM(CASE WHEN line_total IS NULL THEN 1 ELSE 0 END) as null_count,
    CASE
        WHEN SUM(CASE WHEN line_total IS NULL THEN 1 ELSE 0 END) = 0 THEN 'PASS'
        ELSE 'FAIL - Null line_totals found'
    END as result
FROM raw_order_lines;

SELECT
    'quantity_not_null' as check_name,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) as null_count,
    CASE
        WHEN SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) = 0 THEN 'PASS'
        ELSE 'FAIL - Null quantities found'
    END as result
FROM raw_order_lines;
