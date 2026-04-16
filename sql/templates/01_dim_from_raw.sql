-- ============================================================
-- PATTERN : Dimension table from raw CSV data
-- ============================================================
-- A dimension describes WHO, WHAT, WHERE, or WHEN.
-- Each row is one entity (one customer, one product, one store).
-- The surrogate key (_key) is an integer you control.
-- The natural key (_id) is the business identifier from the source.
-- ============================================================

CREATE OR REPLACE TABLE dim_customer AS
SELECT
    -- Surrogate key (auto-generated integer)
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,

    -- Natural key (from source system)
    customer_id,

    -- Descriptive attributes (the "context" for analysis)
    customer_name,
    segment,
    city,
    province,

    -- Metadata
    CURRENT_DATE AS loaded_at

FROM raw_customers
WHERE customer_id IS NOT NULL;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- 1. Every key should be unique:
SELECT 'unique_keys' AS check,
       CASE WHEN COUNT(*) = COUNT(DISTINCT customer_key)
            THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_customer;

-- 2. No null natural keys:
SELECT 'no_null_ids' AS check,
       CASE WHEN SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) = 0
            THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_customer;
