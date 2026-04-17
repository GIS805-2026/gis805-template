-- ============================================================
-- 06_identity.sql - Verify dataset identity and fingerprinting
-- Run: duckdb db/nexamart.duckdb < validation/checks/06_identity.sql
-- ============================================================

SELECT '=== DATASET IDENTITY CHECKS ===' as check_category;

-- Check order ID range (fingerprinted per student)
SELECT
    'order_id_range' as check_name,
    MIN(CAST(REPLACE(order_id, 'ORD', '') AS INTEGER)) as min_order_num,
    MAX(CAST(REPLACE(order_id, 'ORD', '') AS INTEGER)) as max_order_num,
    'INFO - Order ID range identifies your dataset' as result
FROM raw_orders;

-- Regional distribution (varies by student)
SELECT
    'regional_distribution' as check_name,
    province,
    COUNT(*) as store_count,
    'INFO - Regional skew is unique to your dataset' as result
FROM raw_stores
GROUP BY province
ORDER BY store_count DESC;

-- Category distribution in orders
SELECT
    'category_distribution' as check_name,
    p.category,
    COUNT(*) as line_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as pct,
    'INFO - Category mix is unique to your dataset' as result
FROM raw_order_lines ol
JOIN raw_products p ON ol.product_id = p.product_id
GROUP BY p.category
ORDER BY line_count DESC;

-- Customer segment distribution
SELECT
    'segment_distribution' as check_name,
    segment,
    COUNT(*) as customer_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as pct,
    'INFO - Segment distribution is unique to your dataset' as result
FROM raw_customers
GROUP BY segment
ORDER BY customer_count DESC;
