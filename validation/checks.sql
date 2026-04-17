-- ============================================================
-- checks.sql — Validation de l'entrepôt NexaMart
-- ============================================================
-- Exécuté par : make check  /  .\run.ps1 check
-- Produit : validation/results/check_results.txt
--
-- Convention : chaque check retourne check_type, detail, result (PASS/FAIL)
-- ============================================================

-- ─────────────────────────────────────────────
-- 1. Existence des tables clés
-- ─────────────────────────────────────────────
SELECT 'TABLE_EXISTS' AS check_type,
       table_name     AS detail,
       'PASS'         AS result
FROM information_schema.tables
WHERE table_schema = 'main'
  AND table_name IN (
      'dim_date','dim_product','dim_store','dim_customer','dim_channel',
      'fact_sales','fact_returns','fact_budget',
      'fact_daily_inventory','fact_order_pipeline',
      'bridge_customer_segment','junk_order_profile','fact_promo_exposure'
  );

-- ─────────────────────────────────────────────
-- 2. Tables non vides (cardinalité minimale)
-- ─────────────────────────────────────────────
SELECT 'ROW_COUNT' AS check_type,
       'dim_date'  AS detail,
       CASE WHEN COUNT(*) >= 365 THEN 'PASS' ELSE 'FAIL -- expected >=365 rows' END AS result
FROM dim_date;

SELECT 'ROW_COUNT' AS check_type,
       'dim_product' AS detail,
       CASE WHEN COUNT(*) >= 10 THEN 'PASS' ELSE 'FAIL -- expected >=10 rows' END AS result
FROM dim_product;

SELECT 'ROW_COUNT' AS check_type,
       'dim_store'  AS detail,
       CASE WHEN COUNT(*) = 10 THEN 'PASS' ELSE 'FAIL -- expected 10 rows' END AS result
FROM dim_store;

SELECT 'ROW_COUNT' AS check_type,
       'dim_channel' AS detail,
       CASE WHEN COUNT(*) = 5 THEN 'PASS' ELSE 'FAIL -- expected 5 rows' END AS result
FROM dim_channel;

SELECT 'ROW_COUNT' AS check_type,
       'dim_customer' AS detail,
       CASE WHEN COUNT(*) >= 100 THEN 'PASS' ELSE 'FAIL -- expected >=100 rows' END AS result
FROM dim_customer;

SELECT 'ROW_COUNT' AS check_type,
       'fact_sales' AS detail,
       CASE WHEN COUNT(*) >= 500 THEN 'PASS' ELSE 'FAIL -- expected >=500 rows' END AS result
FROM fact_sales;

-- ─────────────────────────────────────────────
-- 3. Clés primaires uniques (dimensions)
-- ─────────────────────────────────────────────
SELECT 'PK_UNIQUE' AS check_type,
       'dim_date.date_key' AS detail,
       CASE WHEN COUNT(*) = COUNT(DISTINCT date_key) THEN 'PASS'
            ELSE 'FAIL — duplicate date_key' END AS result
FROM dim_date;

SELECT 'PK_UNIQUE' AS check_type,
       'dim_product.product_id' AS detail,
       CASE WHEN COUNT(*) = COUNT(DISTINCT product_id) THEN 'PASS'
            ELSE 'FAIL — duplicate product_id' END AS result
FROM dim_product;

SELECT 'PK_UNIQUE' AS check_type,
       'dim_store.store_id' AS detail,
       CASE WHEN COUNT(*) = COUNT(DISTINCT store_id) THEN 'PASS'
            ELSE 'FAIL — duplicate store_id' END AS result
FROM dim_store;

SELECT 'PK_UNIQUE' AS check_type,
       'dim_channel.channel_id' AS detail,
       CASE WHEN COUNT(*) = COUNT(DISTINCT channel_id) THEN 'PASS'
            ELSE 'FAIL — duplicate channel_id' END AS result
FROM dim_channel;

SELECT 'PK_UNIQUE' AS check_type,
       'dim_customer.customer_id' AS detail,
       CASE WHEN COUNT(*) = COUNT(DISTINCT customer_id) THEN 'PASS'
            ELSE 'FAIL — duplicate customer_id' END AS result
FROM dim_customer;

-- ─────────────────────────────────────────────
-- 4. FK NOT NULL dans fact_sales
-- ─────────────────────────────────────────────
SELECT 'FK_NOT_NULL' AS check_type,
       'fact_sales.product_id' AS detail,
       CASE WHEN COUNT(*) FILTER (WHERE product_id IS NULL) = 0 THEN 'PASS'
            ELSE 'FAIL — NULL product_id found' END AS result
FROM fact_sales;

SELECT 'FK_NOT_NULL' AS check_type,
       'fact_sales.store_id' AS detail,
       CASE WHEN COUNT(*) FILTER (WHERE store_id IS NULL) = 0 THEN 'PASS'
            ELSE 'FAIL — NULL store_id found' END AS result
FROM fact_sales;

SELECT 'FK_NOT_NULL' AS check_type,
       'fact_sales.customer_id' AS detail,
       CASE WHEN COUNT(*) FILTER (WHERE customer_id IS NULL) = 0 THEN 'PASS'
            ELSE 'FAIL — NULL customer_id found' END AS result
FROM fact_sales;

SELECT 'FK_NOT_NULL' AS check_type,
       'fact_sales.channel_id' AS detail,
       CASE WHEN COUNT(*) FILTER (WHERE channel_id IS NULL) = 0 THEN 'PASS'
            ELSE 'FAIL — NULL channel_id found' END AS result
FROM fact_sales;

-- ─────────────────────────────────────────────
-- 5. Grain verification — fact_sales
--    (order_number + sale_line_id should be unique)
-- ─────────────────────────────────────────────
SELECT 'GRAIN_UNIQUE' AS check_type,
       'fact_sales (order_number, sale_line_id)' AS detail,
       CASE WHEN COUNT(*) = COUNT(DISTINCT (order_number || '-' || sale_line_id))
            THEN 'PASS' ELSE 'FAIL — grain violation' END AS result
FROM fact_sales;

-- ─────────────────────────────────────────────
-- 6. Drill-across réconciliation (S06)
--    Revenue in fact_sales vs budget target — sanity only
-- ─────────────────────────────────────────────
-- TODO (S06) : Uncomment when fact_returns and fact_budget exist
-- SELECT 'RECONCILE' AS check_type,
--        'sales_total vs budget_total' AS detail,
--        CASE WHEN ABS(s.total - b.total) / NULLIF(b.total, 0) < 2.0
--             THEN 'PASS' ELSE 'WARN — large variance' END AS result
-- FROM (SELECT SUM(line_total) AS total FROM fact_sales) s,
--      (SELECT SUM(target_revenue) AS total FROM fact_budget) b;

-- ─────────────────────────────────────────────
-- 7. Bridge weights sum to 1.0 per customer (S08)
-- ─────────────────────────────────────────────
-- TODO (S08) : Uncomment when bridge_customer_segment exists
-- SELECT 'BRIDGE_WEIGHT' AS check_type,
--        'bridge_customer_segment SUM(weight)=1.0' AS detail,
--        CASE WHEN COUNT(*) FILTER (WHERE ABS(w - 1.0) > 0.01) = 0
--             THEN 'PASS' ELSE 'FAIL — weights don''t sum to 1.0' END AS result
-- FROM (SELECT customer_id, SUM(weight) AS w
--       FROM bridge_customer_segment GROUP BY customer_id) t;
