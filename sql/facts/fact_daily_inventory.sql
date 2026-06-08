-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- fact_daily_inventory -- PERIODIC SNAPSHOT FACT (introduite S09)
-- ============================================================
-- GRAIN : une ligne = un produit × un magasin × un jour.
--
-- Caractéristiques du type periodic snapshot :
--   - Une ligne par intervalle régulier (quotidien ici).
--   - quantity_on_hand est semi-additive : additive sur product/store,
--     PAS sur date (on ne somme jamais des stocks sur des jours).
--   - Idéal pour mesures d'état (stock, solde, effectif).
-- ============================================================

CREATE OR REPLACE TABLE fact_daily_inventory AS
SELECT
    ri.snapshot_id,
    CAST(ri.snapshot_date AS DATE) AS snapshot_date,
    p.product_key,
    st.store_key,
    CAST(ri.quantity_on_hand AS INTEGER)   AS quantity_on_hand,
    CAST(ri.quantity_on_order AS INTEGER)  AS quantity_on_order,
    CAST(ri.days_of_supply AS DECIMAL(5,1)) AS days_of_supply
FROM raw_fact_daily_inventory ri
JOIN dim_product p  ON p.product_id = ri.product_id
JOIN dim_store   st ON st.store_id  = ri.store_id;
