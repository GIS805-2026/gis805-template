-- ============================================================
-- fact_daily_inventory.sql — Snapshot périodique (S09)
-- ============================================================
-- Grain : 1 ligne = produit × magasin × date
-- Mesures : quantity_on_hand, quantity_on_order
-- Additivité : SEMI-ADDITIVE (ne PAS sommer sur le temps)
-- Type de fait : Periodic Snapshot (Type 2)
-- ============================================================

-- TODO (S09) : Écrire le DDL CREATE TABLE
--   - FK vers dim_date, dim_product, dim_store
--   - Documenter pourquoi SUM(quantity_on_hand) sur le temps est FAUX

-- TODO (S09) : Écrire la requête INSERT/SELECT depuis les données staging
