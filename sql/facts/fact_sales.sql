-- ============================================================
-- fact_sales.sql — Table de faits transactionnelle (S02)
-- ============================================================
-- Grain : 1 ligne = 1 ligne de commande (order_id, line_item_id)
-- Mesures : revenue, quantity, discount_amount, cost
-- Additivité : toutes les mesures sont additives
-- ============================================================

-- TODO (S02) : Écrire le DDL CREATE TABLE avec :
--   - Clé dégénérée : order_number (S04)
--   - FK vers dim_date, dim_product, dim_store, dim_customer, dim_channel
--   - FK vers junk_order_profile (S04)
--   - Grain statement ci-dessus comme commentaire permanent

-- TODO (S02) : Écrire la requête INSERT/SELECT depuis les données staging
