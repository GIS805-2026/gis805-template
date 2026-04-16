-- ============================================================
-- checks.sql - Consolidated validation checks for NexaMart
-- Run: duckdb db/nexamart.duckdb < validation/checks.sql
-- ============================================================
-- This file consolidates all validation checks into a single script.
-- Individual checks are also available in validation/checks/ folder.
-- ============================================================

-- ============================================================
-- SECTION 0: EXISTENCE CHECKS
-- ============================================================
SELECT '=== [0] EXISTENCE CHECKS ===' as section;

SELECT 'raw_tables' as check, COUNT(*) as count,
       CASE WHEN COUNT(*) >= 5 THEN 'PASS' ELSE 'FAIL' END as result
FROM information_schema.tables WHERE table_name LIKE 'raw_%';

SELECT 'dim_tables' as check, COUNT(*) as count,
       CASE WHEN COUNT(*) >= 1 THEN 'PASS' ELSE 'INFO - No dims yet' END as result
FROM information_schema.tables WHERE table_name LIKE 'dim_%';

SELECT 'fact_tables' as check, COUNT(*) as count,
       CASE WHEN COUNT(*) >= 1 THEN 'PASS' ELSE 'INFO - No facts yet' END as result
FROM information_schema.tables WHERE table_name LIKE 'fact_%';

-- ============================================================
-- SECTION 1: ROW COUNT CHECKS
-- ============================================================
SELECT '=== [1] ROW COUNT CHECKS ===' as section;

SELECT 'raw_customers' as table_name, COUNT(*) as rows,
       CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM raw_customers;

SELECT 'raw_products' as table_name, COUNT(*) as rows,
       CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM raw_products;

SELECT 'raw_stores' as table_name, COUNT(*) as rows,
       CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM raw_stores;

SELECT 'raw_orders' as table_name, COUNT(*) as rows,
       CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM raw_orders;

SELECT 'raw_order_lines' as table_name, COUNT(*) as rows,
       CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM raw_order_lines;

-- ============================================================
-- SECTION 2: KEY INTEGRITY CHECKS
-- ============================================================
SELECT '=== [2] KEY INTEGRITY CHECKS ===' as section;

SELECT 'customer_key_unique' as check,
       CASE WHEN COUNT(*) = COUNT(DISTINCT customer_id) THEN 'PASS' ELSE 'FAIL' END as result
FROM raw_customers;

SELECT 'product_key_unique' as check,
       CASE WHEN COUNT(*) = COUNT(DISTINCT product_id) THEN 'PASS' ELSE 'FAIL' END as result
FROM raw_products;

SELECT 'store_key_unique' as check,
       CASE WHEN COUNT(*) = COUNT(DISTINCT store_id) THEN 'PASS' ELSE 'FAIL' END as result
FROM raw_stores;

SELECT 'order_key_unique' as check,
       CASE WHEN COUNT(*) = COUNT(DISTINCT order_id) THEN 'PASS' ELSE 'FAIL' END as result
FROM raw_orders;

-- ============================================================
-- SECTION 3: NULL POLICY CHECKS
-- ============================================================
SELECT '=== [3] NULL POLICY CHECKS ===' as section;

SELECT 'customer_id_not_null' as check,
       SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) as nulls,
       CASE WHEN SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) = 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM raw_customers;

SELECT 'product_id_not_null' as check,
       SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) as nulls,
       CASE WHEN SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) = 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM raw_products;

SELECT 'order_id_not_null' as check,
       SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) as nulls,
       CASE WHEN SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) = 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM raw_orders;

-- ============================================================
-- SECTION 4: RECONCILIATION CHECKS
-- ============================================================
SELECT '=== [4] RECONCILIATION CHECKS ===' as section;

SELECT 'line_total_calc' as check,
       COUNT(*) as mismatches,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'WARNING' END as result
FROM raw_order_lines
WHERE ABS(line_total - (quantity * unit_price * (1 - COALESCE(discount_pct, 0)))) > 0.01;

SELECT 'total_revenue_positive' as check,
       SUM(line_total)::DECIMAL(15,2) as total,
       CASE WHEN SUM(line_total) > 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM raw_order_lines;

-- ============================================================
-- SECTION 5: DUPLICATE RISK CHECKS
-- ============================================================
SELECT '=== [5] DUPLICATE RISK CHECKS ===' as section;

SELECT 'duplicate_customer_risk' as check,
       COUNT(*) as risks,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'INFO' END as result
FROM (
    SELECT customer_name, email, COUNT(*) as cnt
    FROM raw_customers GROUP BY customer_name, email HAVING COUNT(*) > 1
);

SELECT 'duplicate_product_risk' as check,
       COUNT(*) as risks,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'INFO' END as result
FROM (
    SELECT product_name, category, COUNT(*) as cnt
    FROM raw_products GROUP BY product_name, category HAVING COUNT(*) > 1
);

-- ============================================================
-- SECTION 6: IDENTITY CHECK
-- ============================================================
SELECT '=== [6] DATASET IDENTITY ===' as section;

SELECT 'order_id_range' as check,
       MIN(CAST(REPLACE(order_id, 'ORD', '') AS INTEGER)) as min_id,
       MAX(CAST(REPLACE(order_id, 'ORD', '') AS INTEGER)) as max_id,
       'INFO - Unique to your dataset' as result
FROM raw_orders;

SELECT 'regional_distribution' as check, province, COUNT(*) as stores
FROM raw_stores GROUP BY province ORDER BY stores DESC LIMIT 5;

-- ============================================================
-- SUMMARY
-- ============================================================
SELECT '=== VALIDATION COMPLETE ===' as summary;
