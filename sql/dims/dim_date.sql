-- ============================================================
-- dim_date.sql - Date dimension template
-- ============================================================
-- The date dimension is one of the most important dimensions
-- in any dimensional model. It enables time-based analysis.
--
-- Usage: Run this script to create a standard date dimension
-- covering the relevant date range for NexaMart data.
-- ============================================================

-- Create date dimension covering 2020-2026
CREATE OR REPLACE TABLE dim_date AS
WITH date_spine AS (
    SELECT 
        CAST('2020-01-01' AS DATE) + (i * INTERVAL '1 day') as full_date
    FROM generate_series(0, 2556) as t(i)  -- ~7 years
)
SELECT
    -- Surrogate key (YYYYMMDD format)
    CAST(strftime(full_date, '%Y%m%d') AS INTEGER) as date_key,
    
    -- Natural key
    full_date,
    
    -- Calendar attributes
    EXTRACT(YEAR FROM full_date) as year,
    EXTRACT(MONTH FROM full_date) as month,
    EXTRACT(DAY FROM full_date) as day,
    EXTRACT(QUARTER FROM full_date) as quarter,
    EXTRACT(WEEK FROM full_date) as week_of_year,
    EXTRACT(DAYOFYEAR FROM full_date) as day_of_year,
    EXTRACT(DAYOFWEEK FROM full_date) as day_of_week,
    
    -- Text representations
    strftime(full_date, '%B') as month_name,
    strftime(full_date, '%b') as month_short,
    strftime(full_date, '%A') as day_name,
    strftime(full_date, '%a') as day_short,
    
    -- Derived attributes
    CASE WHEN EXTRACT(DAYOFWEEK FROM full_date) IN (0, 6) THEN TRUE ELSE FALSE END as is_weekend,
    
    -- Fiscal calendar (assuming fiscal year starts in April)
    CASE 
        WHEN EXTRACT(MONTH FROM full_date) >= 4 THEN EXTRACT(YEAR FROM full_date)
        ELSE EXTRACT(YEAR FROM full_date) - 1
    END as fiscal_year,
    
    -- Period keys for hierarchy navigation
    EXTRACT(YEAR FROM full_date) * 100 + EXTRACT(MONTH FROM full_date) as year_month_key,
    EXTRACT(YEAR FROM full_date) * 10 + EXTRACT(QUARTER FROM full_date) as year_quarter_key

FROM date_spine
WHERE full_date <= CURRENT_DATE + INTERVAL '1 year';

-- Verify
SELECT 
    'dim_date created' as status,
    MIN(full_date) as min_date,
    MAX(full_date) as max_date,
    COUNT(*) as row_count
FROM dim_date;
