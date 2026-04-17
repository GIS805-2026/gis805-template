-- ============================================================
-- PATTERN : Validation / reconciliation checks
-- ============================================================
-- Every model needs proof that it's not lying.
-- Run these checks after building your facts and dimensions.
-- A passing model earns trust. A failing model earns questions.
-- ============================================================

-- CHECK 1: Row count sanity
-- Are the counts plausible? Not zero? Not suspiciously round?
SELECT 'row_counts' AS check,
       (SELECT COUNT(*) FROM fact_sales) AS fact_rows,
       (SELECT COUNT(*) FROM dim_customer) AS dim_customer_rows,
       (SELECT COUNT(*) FROM dim_product) AS dim_product_rows;

-- CHECK 2: Referential integrity
-- Every FK in the fact should point to an existing dimension row.
-- (This template uses natural keys -- adapt if you introduced _key surrogates.)
SELECT 'orphan_customers' AS check,
       COUNT(*) AS orphans,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM fact_sales f
LEFT JOIN dim_customer d ON f.customer_id = d.customer_id
WHERE d.customer_id IS NULL;

SELECT 'orphan_products' AS check,
       COUNT(*) AS orphans,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM fact_sales f
LEFT JOIN dim_product d ON f.product_id = d.product_id
WHERE d.product_id IS NULL;

-- CHECK 3: Reconciliation
-- Does the total from the fact table match the total from raw data?
SELECT 'revenue_reconciliation' AS check,
       (SELECT SUM(line_total) FROM fact_sales)::DECIMAL(15,2) AS fact_total,
       (SELECT SUM(line_total) FROM raw_fact_sales)::DECIMAL(15,2) AS raw_total,
       CASE
           WHEN ABS(
               (SELECT SUM(line_total) FROM fact_sales) -
               (SELECT SUM(line_total) FROM raw_fact_sales)
           ) < 0.01
           THEN 'PASS'
           ELSE 'FAIL - totals diverge'
       END AS result;

-- CHECK 4: Duplicate grain detection
-- If the grain is (order_number, sale_line_id), are there duplicates?
SELECT 'duplicate_grains' AS check,
       COUNT(*) AS duplicates,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM (
    SELECT order_number, sale_line_id, COUNT(*) AS cnt
    FROM fact_sales
    GROUP BY order_number, sale_line_id
    HAVING COUNT(*) > 1
);

-- CHECK 5: NULL measures
-- Measures should not be NULL in a fact table.
SELECT 'null_measures' AS check,
       SUM(CASE WHEN line_total IS NULL THEN 1 ELSE 0 END) AS null_totals,
       SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_qty,
       CASE
           WHEN SUM(CASE WHEN line_total IS NULL THEN 1 ELSE 0 END) = 0
            AND SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) = 0
           THEN 'PASS' ELSE 'FAIL'
       END AS result
FROM fact_sales;
