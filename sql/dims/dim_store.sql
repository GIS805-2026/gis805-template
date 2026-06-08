-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- dim_store (introduite S02)
-- ============================================================
-- Grain : une ligne = un magasin.
-- Canonique : toutes les équipes ont les 10 mêmes magasins.
-- ============================================================

CREATE OR REPLACE TABLE dim_store AS
SELECT
    ROW_NUMBER() OVER (ORDER BY store_id) AS store_key,
    store_id,
    store_name,
    city,
    region,
    province,
    store_type
FROM raw_dim_store
WHERE store_id IS NOT NULL;
