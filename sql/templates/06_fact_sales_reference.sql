-- ============================================================
-- PATTERN : fact_sales reference build (full Kimball convention)
-- ============================================================
-- This is the LONG-FORM, pedagogical version of fact_sales. It goes
-- further than template 02 (which used natural keys for simplicity) and
-- shows every decision you actually have to make when you ship a fact
-- table in the real world.
--
-- READ IT END-TO-END the first time. Do NOT copy-paste into sql/facts/ --
-- your real version should be YOUR reasoning, not ours.
--
-- Compare with:
--   - 02_fact_with_grain.sql  : same table, natural-key version (simpler)
--   - 03_scd_type2.sql        : the dim_customer this fact depends on
--   - docs/worked-examples/s02-star-schema-walkthrough.md
-- ============================================================

-- ------------------------------------------------------------
-- Decision 1 : What is the GRAIN ?
-- ------------------------------------------------------------
-- ONE ROW = ONE ORDER LINE.
-- Identified by the degenerate dimension (order_number, sale_line_id).
-- This choice is IRREVERSIBLE : every downstream query, every brief,
-- every measure additivity decision flows from it.
--
-- If you mix header-level rows (one per order) with line-level rows
-- (one per product in an order) in the same table, you have MIXED GRAIN
-- and every SUM() you write becomes a landmine. Don't.

-- ------------------------------------------------------------
-- Decision 2 : Which keys go into the fact ?
-- ------------------------------------------------------------
-- Kimball rule : facts join dimensions via SURROGATE KEYS (dim_customer.
-- customer_key) -- NOT natural keys (raw_fact_sales.customer_id).
--
-- WHY ? Because dim_customer is SCD Type 2. A single customer_id has
-- multiple versions over time (one per city move, segment change,
-- province change). At the moment a sale happens, the fact must point
-- at the VERSION that was active on that date, not the current one.
-- A natural-key join (customer_id = customer_id) would always pick the
-- latest version and lose history.
--
-- The validation/checks.sql file enforces this : FK_NOT_NULL checks run
-- on *_key columns, not *_id.

-- ------------------------------------------------------------
-- Decision 3 : Which measures, and how additive are they ?
-- ------------------------------------------------------------
-- ADDITIVE (can be SUM'd across any dimension) :
--   quantity, net_price, line_total, margin_amount
-- NON-ADDITIVE (only meaningful averaged, weighted by line_total) :
--   discount_pct, unit_price
-- SEMI-ADDITIVE (SUM across most dims but not across time) :
--   -- fact_sales has none; inventory snapshots (S09) do.
--
-- Put additive measures in the fact. Leave ratios to the BI layer.

CREATE OR REPLACE TABLE fact_sales AS
SELECT
    -- === Degenerate dimensions (live in the fact) ===
    rs.sale_line_id,                            -- the GRAIN identifier
    rs.order_number,                             -- no separate dim_order
    CAST(rs.order_date AS DATE) AS order_date,   -- joins to dim_date.date_key

    -- === Surrogate FKs (point to a SPECIFIC version of each dim) ===
    c.customer_key,    -- SCD2 : version active at order_date
    p.product_key,     -- SCD1 : always current version
    st.store_key,      -- SCD1
    ch.channel_key,    -- SCD1

    -- === Additive measures ===
    CAST(rs.quantity     AS INTEGER)      AS quantity,
    CAST(rs.unit_price   AS DECIMAL(10,2)) AS unit_price,
    CAST(rs.discount_pct AS DECIMAL(5,2))  AS discount_pct,
    CAST(rs.net_price    AS DECIMAL(10,2)) AS net_price,
    CAST(rs.line_total   AS DECIMAL(10,2)) AS line_total,

    -- === Derived measure ===
    -- margin = (selling price - product cost) * quantity.
    -- Stored in the fact so downstream briefs don't have to re-derive it
    -- and so it is SUM-able like any other additive measure.
    CAST((rs.net_price - p.unit_cost) * rs.quantity AS DECIMAL(10,2)) AS margin_amount

FROM raw_fact_sales rs

-- ------------------------------------------------------------
-- SCD2 resolution on dim_customer
-- ------------------------------------------------------------
-- We pick the ONE row in dim_customer whose validity window covers
-- the order_date. If dim_customer is correctly built, exactly one row
-- per (customer_id, order_date) satisfies the BETWEEN -- otherwise the
-- grain check below will FAIL and you have a SCD2 bug to fix first.
JOIN dim_customer c
    ON  c.customer_id = rs.customer_id
    AND CAST(rs.order_date AS DATE) BETWEEN c.effective_from AND c.effective_to

-- SCD1 dimensions : simple natural-key joins resolve to the current key.
JOIN dim_product p  ON p.product_id  = rs.product_id
JOIN dim_store   st ON st.store_id   = rs.store_id
JOIN dim_channel ch ON ch.channel_id = rs.channel_id;

-- ============================================================
-- VERIFICATION (run every time you rebuild this fact)
-- ============================================================
-- 1. Grain uniqueness : sale_line_id alone identifies the row.
--    If this FAILS, your dim_customer SCD2 is probably producing
--    overlapping validity windows -- fix the dim, not the fact.
SELECT 'fact_sales.grain_unique' AS check_name,
       CASE WHEN COUNT(*) = COUNT(DISTINCT sale_line_id)
            THEN 'PASS' ELSE 'FAIL -- duplicate sale_line_id' END AS result
FROM fact_sales;

-- 2. No orphan FKs : every *_key resolves (INNER JOIN already guarantees
--    this, but an explicit check documents the invariant).
SELECT 'fact_sales.no_null_keys' AS check_name,
       CASE WHEN COUNT(*) FILTER (
                WHERE customer_key IS NULL OR product_key IS NULL
                   OR store_key    IS NULL OR channel_key IS NULL
            ) = 0
            THEN 'PASS' ELSE 'FAIL -- NULL surrogate key' END AS result
FROM fact_sales;

-- 3. Reconcile row count with the source. A large gap here usually means
--    a SCD2 window left a date uncovered, or raw data has a dangling FK.
SELECT 'fact_sales.reconcile_rowcount' AS check_name,
       (SELECT COUNT(*) FROM raw_fact_sales) AS source_rows,
       (SELECT COUNT(*) FROM fact_sales)     AS fact_rows,
       CASE WHEN (SELECT COUNT(*) FROM fact_sales)
                 = (SELECT COUNT(*) FROM raw_fact_sales)
            THEN 'PASS' ELSE 'INVESTIGATE -- rows dropped at JOIN' END AS result;

-- 4. Sanity : measures are non-negative where business logic says so.
SELECT 'fact_sales.non_negative_measures' AS check_name,
       CASE WHEN MIN(line_total) >= 0 AND MIN(quantity) >= 0
            THEN 'PASS' ELSE 'WARN -- negative quantity or total' END AS result
FROM fact_sales;
