-- ============================================================
-- bridge_customer_segment.sql — Pont pondéré M:N (S08)
-- ============================================================
-- Grain : 1 ligne = 1 association client ↔ segment
-- Colonnes : customer_key, segment_key, weight
-- Contrainte : SUM(weight) = 1.0 par client
-- Rôle : Allouer le revenu proportionnellement sans double-comptage
-- ============================================================

-- TODO (S08) : Écrire le DDL CREATE TABLE
--   - FK vers dim_customer (customer_key), dim_segment (segment_key)
--   - Colonne weight DECIMAL(5,4)

-- TODO (S08) : Écrire la requête INSERT/SELECT depuis les données staging
-- TODO (S08) : Écrire la requête de réconciliation :
--   SUM(revenue × weight) doit égaler SUM(revenue) total
