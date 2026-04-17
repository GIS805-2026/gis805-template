-- ============================================================
-- 00_existence.sql - Verify required objects exist
-- Run: duckdb db/nexamart.duckdb < validation/checks/00_existence.sql
-- ============================================================

-- This script checks that required tables and views exist.
-- Customize based on assignment requirements.

SELECT '=== EXISTENCE CHECKS ===' as check_category;

-- Check raw tables exist
SELECT
    'raw_tables' as check_name,
    CASE
        WHEN COUNT(*) >= 5 THEN 'PASS'
        ELSE 'FAIL - Missing raw tables'
    END as result,
    COUNT(*) as raw_table_count
FROM information_schema.tables
WHERE table_name LIKE 'raw_%';

-- Check for required dimension tables (customize per assignment)
SELECT
    'dim_tables' as check_name,
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'INFO - No dimension tables yet (expected for early assignments)'
    END as result,
    COUNT(*) as dim_table_count
FROM information_schema.tables
WHERE table_name LIKE 'dim_%';

-- Check for required fact tables (customize per assignment)
SELECT
    'fact_tables' as check_name,
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'INFO - No fact tables yet (expected for early assignments)'
    END as result,
    COUNT(*) as fact_table_count
FROM information_schema.tables
WHERE table_name LIKE 'fact_%';

-- List all tables/views for reference
SELECT
    'all_objects' as check_name,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'main'
ORDER BY table_type, table_name;
