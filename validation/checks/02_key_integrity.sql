-- ============================================================
-- 02_key_integrity.sql - Verify key uniqueness and referential integrity
-- Run: duckdb db/nexamart.duckdb < validation/checks/02_key_integrity.sql
-- ============================================================

SELECT '=== KEY INTEGRITY CHECKS ===' as check_category;

-- Customer key uniqueness
SELECT
    'customer_key_unique' as check_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT customer_id) as unique_keys,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT customer_id) THEN 'PASS'
        ELSE 'FAIL - Duplicate customer_ids'
    END as result
FROM raw_customers;

-- Product key uniqueness
SELECT
    'product_key_unique' as check_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT product_id) as unique_keys,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT product_id) THEN 'PASS'
        ELSE 'FAIL - Duplicate product_ids'
    END as result
FROM raw_products;

-- Store key uniqueness
SELECT
    'store_key_unique' as check_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT store_id) as unique_keys,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT store_id) THEN 'PASS'
        ELSE 'FAIL - Duplicate store_ids'
    END as result
FROM raw_stores;

-- Order key uniqueness
SELECT
    'order_key_unique' as check_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT order_id) as unique_keys,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT order_id) THEN 'PASS'
        ELSE 'FAIL - Duplicate order_ids'
    END as result
FROM raw_orders;

-- Order line composite key uniqueness
SELECT
    'order_line_key_unique' as check_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT order_id || '-' || line_number) as unique_keys,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT order_id || '-' || line_number) THEN 'PASS'
        ELSE 'FAIL - Duplicate order_id + line_number combinations'
    END as result
FROM raw_order_lines;

-- Referential integrity: orders -> customers
SELECT
    'orders_customer_fk' as check_name,
    COUNT(*) as orphan_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL - Orders reference non-existent customers'
    END as result
FROM raw_orders o
LEFT JOIN raw_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Referential integrity: orders -> stores
SELECT
    'orders_store_fk' as check_name,
    COUNT(*) as orphan_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL - Orders reference non-existent stores'
    END as result
FROM raw_orders o
LEFT JOIN raw_stores s ON o.store_id = s.store_id
WHERE s.store_id IS NULL;

-- Referential integrity: order_lines -> products
SELECT
    'order_lines_product_fk' as check_name,
    COUNT(*) as orphan_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL - Order lines reference non-existent products'
    END as result
FROM raw_order_lines ol
LEFT JOIN raw_products p ON ol.product_id = p.product_id
WHERE p.product_id IS NULL;
