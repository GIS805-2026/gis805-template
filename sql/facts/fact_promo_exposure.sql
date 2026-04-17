-- ============================================================
-- fact_promo_exposure.sql — Fait sans mesure / Factless fact (S09)
-- ============================================================
-- Grain : 1 ligne = produit × magasin × promotion × date
-- Mesures : AUCUNE (l'existence de la ligne EST le fait)
-- Mesure implicite : COUNT(*)
-- Type de fait : Factless Fact (Type 4)
-- ============================================================

-- TODO (S09) : Écrire le DDL CREATE TABLE
--   - FK vers dim_date, dim_product, dim_store, dim_promo
--   - Aucune colonne de mesure numérique

-- TODO (S09) : Écrire la requête INSERT/SELECT depuis les données staging
