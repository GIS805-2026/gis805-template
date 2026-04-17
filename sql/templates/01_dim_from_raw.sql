-- ============================================================
-- PATTERN : Dimension table from raw CSV data
-- ============================================================
-- A dimension describes WHO, WHAT, WHERE, or WHEN.
-- Each row is one entity (one customer, one product, one store).
--
-- Two key conventions used below:
--   * Natural key  (_id)  : the business identifier from the source system
--                            (e.g. customer_id = "CUS-00042")
--   * Surrogate key (_key): an integer you control, independent of the source
--                            (useful for SCD2 where the same _id has several versions)
--
-- This pattern reads from `raw_dim_customer` -- the table produced by
-- `make load` after `make generate` drops dim_customer.csv into data/synthetic.
-- ============================================================

CREATE OR REPLACE TABLE dim_customer AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,  -- surrogate
    customer_id,                                                -- natural key
    first_name || ' ' || last_name             AS full_name,
    loyalty_segment,
    city,
    province,
    email_domain,
    CAST(join_date AS DATE)                    AS join_date,
    CURRENT_DATE                                AS loaded_at
FROM raw_dim_customer
WHERE customer_id IS NOT NULL;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- 1. Every surrogate key should be unique:
SELECT
    'unique_surrogate_keys' AS check_name,
    CASE WHEN COUNT(*) = COUNT(DISTINCT customer_key) THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_customer;

-- 2. No null natural keys:
SELECT
    'no_null_natural_keys' AS check_name,
    CASE WHEN COUNT(*) FILTER (WHERE customer_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_customer;
