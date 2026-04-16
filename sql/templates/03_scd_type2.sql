-- ============================================================
-- PATTERN : Slowly Changing Dimension Type 2 (SCD-2) in DuckDB
-- ============================================================
-- SCD-2 preserves historical truth.
-- When a customer changes segment, we keep BOTH versions:
--   - the old row (valid_to = date of change)
--   - the new row (valid_from = date of change, is_current = true)
--
-- WHY: so that a sale from 2024 is reported under the segment
-- the customer belonged to AT THE TIME OF THE SALE.
-- ============================================================

-- Step 1: Create the SCD-2 dimension structure
CREATE OR REPLACE TABLE dim_customer_scd2 (
    customer_key   INTEGER,        -- surrogate key (unique per version)
    customer_id    VARCHAR,        -- natural key (same across versions)
    customer_name  VARCHAR,
    segment        VARCHAR,        -- the attribute that changes
    city           VARCHAR,
    province       VARCHAR,
    valid_from     DATE,
    valid_to       DATE,           -- NULL = still current
    is_current     BOOLEAN
);

-- Step 2: Load initial snapshot (all current)
INSERT INTO dim_customer_scd2
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
    customer_id,
    customer_name,
    segment,
    city,
    province,
    CAST('2024-01-01' AS DATE) AS valid_from,
    NULL AS valid_to,
    TRUE AS is_current
FROM raw_customers;

-- Step 3: Apply a change (example: customer CUST000042 changes segment)
-- First, close the current version:
UPDATE dim_customer_scd2
SET valid_to = CAST('2025-06-15' AS DATE),
    is_current = FALSE
WHERE customer_id = 'CUST000042'
  AND is_current = TRUE;

-- Then, insert the new version:
INSERT INTO dim_customer_scd2
VALUES (
    (SELECT MAX(customer_key) + 1 FROM dim_customer_scd2),
    'CUST000042',
    'Jean Tremblay',       -- same name
    'Premium',             -- NEW segment (was 'Standard')
    'Montreal',
    'QC',
    CAST('2025-06-15' AS DATE),  -- valid from change date
    NULL,                         -- still current
    TRUE
);

-- ============================================================
-- VERIFICATION
-- ============================================================
-- 1. Only one current version per customer:
SELECT 'one_current_per_customer' AS check,
       CASE WHEN MAX(cnt) = 1 THEN 'PASS' ELSE 'FAIL' END AS result
FROM (
    SELECT customer_id, COUNT(*) AS cnt
    FROM dim_customer_scd2
    WHERE is_current = TRUE
    GROUP BY customer_id
);

-- 2. No gaps in valid_from/valid_to for the same customer:
SELECT 'history_chain' AS check, customer_id,
       valid_from, valid_to, is_current
FROM dim_customer_scd2
WHERE customer_id = 'CUST000042'
ORDER BY valid_from;
