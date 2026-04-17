-- ============================================================
-- fact_returns.sql — Table de faits transactionnelle (S06)
-- ============================================================
-- Grain : 1 ligne = 1 retour (return_id)
-- Mesures : return_amount, return_quantity
-- Rôle : Partenaire drill-across de fact_sales
--         (NE JAMAIS joindre directement à fact_sales)
-- ============================================================

-- TODO (S06) : Écrire le DDL CREATE TABLE
--   - FK vers dim_date, dim_product, dim_store, dim_customer
--   - Dimensions conformes avec fact_sales

-- TODO (S06) : Écrire la requête INSERT/SELECT depuis les données staging
