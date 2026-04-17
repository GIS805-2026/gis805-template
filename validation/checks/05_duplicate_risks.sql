-- ============================================================
-- 05_duplicate_risks.sql - Check for potential duplicate issues
-- Run: duckdb db/nexamart.duckdb < validation/checks/05_duplicate_risks.sql
-- ============================================================

SELECT '=== DUPLICATE RISK CHECKS ===' as check_category;

-- Look for potential duplicate customers (same name + email)
SELECT
    'duplicate_customer_risk' as check_name,
    COUNT(*) as potential_duplicates,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'INFO - Check for potential duplicate customers'
    END as result
FROM (
    SELECT customer_name, email, COUNT(*) as cnt
    FROM raw_customers
    GROUP BY customer_name, email
    HAVING COUNT(*) > 1
);

-- Look for potential duplicate products (same name + category)
SELECT
    'duplicate_product_risk' as check_name,
    COUNT(*) as potential_duplicates,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'INFO - Check for potential duplicate products'
    END as result
FROM (
    SELECT product_name, category, COUNT(*) as cnt
    FROM raw_products
    GROUP BY product_name, category
    HAVING COUNT(*) > 1
);

-- Check for same customer ordering same product multiple times same day
-- (not necessarily wrong, but worth noting)
SELECT
    'same_day_repeat_orders' as check_name,
    COUNT(*) as repeat_count,
    'INFO - May be legitimate repeat purchases' as result
FROM (
    SELECT
        o.customer_id,
        ol.product_id,
        o.order_date,
        COUNT(*) as order_count
    FROM raw_orders o
    JOIN raw_order_lines ol ON o.order_id = ol.order_id
    GROUP BY o.customer_id, ol.product_id, o.order_date
    HAVING COUNT(*) > 1
);
