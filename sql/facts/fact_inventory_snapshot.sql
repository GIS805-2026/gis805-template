-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- fact_inventory_snapshot -- periodic snapshot (introduite S06)
-- ============================================================
-- GRAIN : une ligne = un produit × un magasin × une date de snapshot.
--
-- Mesures semi-additives : quantity_on_hand ne se somme PAS sur la date
-- (faire AVG ou prendre le dernier snapshot). Se somme normalement sur
-- product et store.
-- ============================================================

CREATE OR REPLACE TABLE fact_inventory_snapshot AS
SELECT
    ri.snapshot_id,
    CAST(ri.snapshot_date AS DATE) AS snapshot_date,
    p.product_key,
    st.store_key,
    CAST(ri.quantity_on_hand AS INTEGER)  AS quantity_on_hand,
    CAST(ri.quantity_on_order AS INTEGER) AS quantity_on_order,
    CAST(ri.reorder_point AS INTEGER)     AS reorder_point,
    -- Flag dérivé pour les alertes stock bas
    CASE WHEN ri.quantity_on_hand < ri.reorder_point THEN TRUE ELSE FALSE END
        AS below_reorder
FROM raw_fact_inventory_snapshot ri
JOIN dim_product p  ON p.product_id = ri.product_id
JOIN dim_store   st ON st.store_id  = ri.store_id;
