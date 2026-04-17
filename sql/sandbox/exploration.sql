-- ============================================================
-- Sandbox area for exploration
-- ============================================================
-- Use this file for ad-hoc queries and exploration.
-- Nothing here needs to be production-ready.
-- ============================================================

-- Example: Quick look at data distributions
-- SELECT * FROM raw_customers LIMIT 10;

-- Example: Check category distribution
-- SELECT category, COUNT(*) as cnt
-- FROM raw_products
-- GROUP BY category
-- ORDER BY cnt DESC;

-- Example: Monthly order trends
-- SELECT
--     DATE_TRUNC('month', CAST(order_date AS DATE)) as month,
--     COUNT(*) as order_count
-- FROM raw_orders
-- GROUP BY 1
-- ORDER BY 1;

-- Your exploration queries below:
