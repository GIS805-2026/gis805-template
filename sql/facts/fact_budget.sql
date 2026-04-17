-- ============================================================
-- fact_budget.sql — Table de faits périodique (S06)
-- ============================================================
-- Grain : 1 ligne = catégorie × magasin × mois
-- Mesures : budget_amount
-- Rôle : Comparaison réel vs cible (drill-across avec fact_sales)
--         Nécessite d'agréger fact_sales au grain du budget avant jointure
-- ============================================================

-- TODO (S06) : Écrire le DDL CREATE TABLE
--   - FK vers dim_date (grain mensuel), dim_product (grain catégorie), dim_store

-- TODO (S06) : Écrire la requête INSERT/SELECT depuis les données staging
