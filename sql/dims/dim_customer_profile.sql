-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- dim_customer_profile -- mini-dimension (introduite S07)
-- ============================================================
-- Grain : une ligne = une combinaison (age_band, spend_band, frequency_band).
--
-- Attributs hautement volatils qu'on extrait de dim_customer pour éviter
-- d'exploser le nombre de versions SCD2. Un changement de spend_band ne
-- crée pas une nouvelle ligne dans dim_customer -- il crée une nouvelle
-- assignation dans fact_sales vers une ligne différente de cette mini-dim.
-- ============================================================

CREATE OR REPLACE TABLE dim_customer_profile AS
SELECT DISTINCT
    DENSE_RANK() OVER (ORDER BY age_band, spend_band, frequency_band) AS profile_key,
    age_band,
    spend_band,
    frequency_band
FROM raw_customer_profile_bands;
