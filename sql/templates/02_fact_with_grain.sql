-- ============================================================
-- PATTERN : Fact table with explicit grain
-- ============================================================
-- A fact table stores MEASURABLE EVENTS at a specific grain.
-- GRAIN = what does ONE ROW represent?
--
-- For this example:
--   GRAIN: one order line (one product in one order)
--   MEASURES: quantity, unit_price, discount_pct, line_total
--   FOREIGN KEYS: point to dimension tables
-- ============================================================

CREATE OR REPLACE TABLE fact_sales AS
SELECT
    -- Foreign keys to dimensions (the "context")
    dc.customer_key,
    dp.product_key,
    ds.store_key,
    dd.date_key,

    -- Degenerate dimension (lives in the fact, no separate table)
    o.order_id AS order_number,

    -- Measures (the "numbers" you analyze)
    ol.quantity,
    ol.unit_price,
    ol.discount_pct,
    ol.line_total,

    -- Derived measure
    ol.quantity * ol.unit_price AS gross_amount

FROM raw_order_lines ol
JOIN raw_orders o        ON ol.order_id = o.order_id
JOIN dim_customer dc     ON o.customer_id = dc.customer_id
JOIN dim_product dp      ON ol.product_id = dp.product_id
JOIN dim_store ds        ON o.store_id = ds.store_id
JOIN dim_date dd         ON CAST(o.order_date AS DATE) = dd.full_date;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- 1. Grain check: each (order_number, product_key) should be unique
SELECT 'grain_unique' AS check,
       COUNT(*) AS total_rows,
       COUNT(DISTINCT (order_number || '-' || CAST(product_key AS VARCHAR))) AS distinct_grains,
       CASE WHEN COUNT(*) = COUNT(DISTINCT (order_number || '-' || CAST(product_key AS VARCHAR)))
            THEN 'PASS' ELSE 'WARNING - duplicate grains' END AS result
FROM fact_sales;

-- 2. No orphan keys:
SELECT 'no_null_fks' AS check,
       SUM(CASE WHEN customer_key IS NULL THEN 1 ELSE 0 END) AS null_customers,
       SUM(CASE WHEN product_key IS NULL THEN 1 ELSE 0 END) AS null_products,
       SUM(CASE WHEN store_key IS NULL THEN 1 ELSE 0 END) AS null_stores
FROM fact_sales;

-- 3. Measures are positive:
SELECT 'positive_totals' AS check,
       CASE WHEN MIN(line_total) >= 0 THEN 'PASS' ELSE 'WARNING' END AS result
FROM fact_sales;
