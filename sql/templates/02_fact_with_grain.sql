-- ============================================================
-- PATTERN : Fact table with explicit grain
-- ============================================================
-- A fact table stores MEASURABLE EVENTS at a specific grain.
-- GRAIN = what does ONE ROW represent?
--
-- For this example (fact_sales as produced by S02 data generator):
--   GRAIN      : one order line (one product in one order)
--   MEASURES   : quantity, unit_price, discount_pct, net_price, line_total
--   FK-to-dims : customer_id, product_id, store_id, channel_id, order_date
--   DEGENERATE : order_number (lives in the fact, no separate dim)
--
-- This pattern uses natural keys (_id) directly. If you want to introduce
-- surrogate keys (_key), see template 03_scd_type2.sql.
-- ============================================================

CREATE OR REPLACE TABLE fact_sales AS
SELECT
    -- Degenerate dimension (no separate table)
    f.order_number,
    f.sale_line_id,

    -- Foreign keys to dimensions (natural keys)
    f.order_date,
    f.customer_id,
    f.product_id,
    f.store_id,
    f.channel_id,

    -- Measures
    f.quantity,
    f.unit_price,
    f.discount_pct,
    f.net_price,
    f.line_total,

    -- Derived measure
    f.quantity * f.unit_price AS gross_amount
FROM raw_fact_sales f;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- 1. Grain uniqueness: (order_number, sale_line_id) must be unique
SELECT
    'grain_unique' AS check_name,
    CASE WHEN COUNT(*) = COUNT(DISTINCT (order_number || '-' || sale_line_id::VARCHAR))
         THEN 'PASS' ELSE 'FAIL -- duplicate grain' END AS result
FROM fact_sales;

-- 2. No NULL FKs
SELECT
    'no_null_fks' AS check_name,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customers,
    COUNT(*) FILTER (WHERE product_id  IS NULL) AS null_products,
    COUNT(*) FILTER (WHERE store_id    IS NULL) AS null_stores,
    COUNT(*) FILTER (WHERE channel_id  IS NULL) AS null_channels
FROM fact_sales;

-- 3. FK integrity: every customer_id in fact_sales exists in dim_customer
SELECT
    'customer_fk_integrity' AS check_name,
    COUNT(*) AS orphan_rows,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM fact_sales f
LEFT JOIN dim_customer d ON f.customer_id = d.customer_id
WHERE d.customer_id IS NULL;

-- 4. Measures are non-negative
SELECT
    'positive_totals' AS check_name,
    CASE WHEN MIN(line_total) >= 0 THEN 'PASS' ELSE 'WARN' END AS result
FROM fact_sales;
