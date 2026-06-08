-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- dim_date -- dimension date conformée (introduite S02)
-- ============================================================
-- Grain : une ligne = une journée civile.
-- Source : raw_dim_date (généré par gen_shared_seeds.py).
-- ============================================================

CREATE OR REPLACE TABLE dim_date AS
SELECT
    CAST(date_key AS DATE)               AS date_key,       -- PK naturelle
    CAST(year AS INTEGER)                AS year,
    CAST(quarter AS INTEGER)             AS quarter,
    CAST(month AS INTEGER)               AS month,
    month_name,
    CAST(week_iso AS INTEGER)            AS week_iso,
    CAST(day_of_week AS INTEGER)         AS day_of_week,
    day_name,
    CAST(is_weekend AS BOOLEAN)          AS is_weekend
FROM raw_dim_date;

-- Vérifications de grain
SELECT 'dim_date.unique_date'    AS check_name,
       CASE WHEN COUNT(*) = COUNT(DISTINCT date_key) THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_date;
