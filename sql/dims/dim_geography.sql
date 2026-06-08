-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- dim_geography -- hiérarchie géographique (introduite S07)
-- ============================================================
-- Grain : une ligne = une ville.
-- Hiérarchie : ville -> région -> province -> pays.
--
-- Traite les NULLs (région inconnue) via un membre explicite 'Unknown'
-- plutôt que NULL, pour simplifier les jointures downstream.
-- ============================================================

CREATE OR REPLACE TABLE dim_geography AS
SELECT
    ROW_NUMBER() OVER (ORDER BY city) AS geography_key,
    city,
    COALESCE(NULLIF(TRIM(region), ''), 'Unknown')   AS region,
    COALESCE(NULLIF(TRIM(province), ''), 'Unknown') AS province,
    COALESCE(NULLIF(TRIM(country), ''), 'Canada')   AS country,
    -- Flag pratique pour filtrer rapidement les lignes à réconcilier
    CASE WHEN region = 'Unknown' OR region IS NULL THEN TRUE ELSE FALSE END AS is_unknown_region
FROM raw_dim_geography;
