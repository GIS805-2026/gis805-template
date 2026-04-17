-- ============================================================
-- fact_order_pipeline.sql — Snapshot accumulant (S09)
-- ============================================================
-- Grain : 1 ligne = 1 cycle de vie de commande (order_id)
-- Dates role-playing : order_date, payment_date, pick_date,
--                      ship_date, delivery_date
-- Type de fait : Accumulating Snapshot (Type 3)
-- SEUL type qui utilise UPDATE (mise à jour à chaque étape)
-- ============================================================

-- TODO (S09) : Écrire le DDL CREATE TABLE
--   - FK multiples vers dim_date (une par étape du pipeline)
--   - FK vers dim_product, dim_store, dim_customer
--   - Colonnes de mesure : days_to_ship, days_to_deliver (calculées)

-- TODO (S09) : Écrire la requête INSERT initiale + logique d'UPDATE
