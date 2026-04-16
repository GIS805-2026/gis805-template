-- ============================================================
-- PATTERN : Many-to-many bridge table (with optional weights)
-- ============================================================
-- PROBLEM: A customer can belong to multiple segments.
--          A campaign can target multiple segments.
--          If you join directly, you get DOUBLE COUNTING.
--
-- SOLUTION: A bridge table sits between the fact and the
--           dimension, carrying a WEIGHT that sums to 1.0
--           per entity. Revenue is allocated proportionally.
-- ============================================================

-- Step 1: Create the bridge table
CREATE OR REPLACE TABLE bridge_customer_segment (
    customer_key   INTEGER,
    segment_key    INTEGER,
    weight         DECIMAL(5,4)  -- allocation factor, sums to 1.0 per customer
);

-- Step 2: Populate (example with equal weights)
-- If a customer belongs to 2 segments, each gets weight 0.5
INSERT INTO bridge_customer_segment
VALUES
    (1, 10, 0.6000),   -- customer 1: 60% Premium
    (1, 20, 0.4000),   -- customer 1: 40% Loyalty
    (2, 10, 1.0000),   -- customer 2: 100% Premium
    (3, 20, 0.5000),   -- customer 3: 50% Loyalty
    (3, 30, 0.5000);   -- customer 3: 50% New

-- ============================================================
-- USAGE: Allocated revenue by segment (no double counting)
-- ============================================================
-- SELECT
--     s.segment_name,
--     SUM(f.line_total * b.weight) AS allocated_revenue
-- FROM fact_sales f
-- JOIN bridge_customer_segment b ON f.customer_key = b.customer_key
-- JOIN dim_segment s              ON b.segment_key = s.segment_key
-- GROUP BY s.segment_name;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- 1. Weights must sum to 1.0 per customer:
SELECT 'weight_sum_check' AS check,
       customer_key,
       SUM(weight)::DECIMAL(5,4) AS total_weight,
       CASE WHEN ABS(SUM(weight) - 1.0) < 0.001
            THEN 'PASS' ELSE 'FAIL' END AS result
FROM bridge_customer_segment
GROUP BY customer_key;

-- 2. No negative weights:
SELECT 'no_negative_weights' AS check,
       CASE WHEN MIN(weight) >= 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM bridge_customer_segment;

-- 3. Total allocated revenue should equal total unallocated revenue:
-- (This is the key reconciliation -- run after joining with facts)
-- SELECT
--     'allocation_reconciliation' AS check,
--     (SELECT SUM(line_total) FROM fact_sales)::DECIMAL(15,2) AS raw_total,
--     SUM(f.line_total * b.weight)::DECIMAL(15,2) AS allocated_total
-- FROM fact_sales f
-- JOIN bridge_customer_segment b ON f.customer_key = b.customer_key;
