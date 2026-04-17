-- ============================================================
-- dim_channel.sql — Dimension canal de vente (Shared Seeds)
-- ============================================================
-- Grain : 1 ligne = 1 canal de vente
-- Source : data/synthetic/team_*/shared/dim_channel.csv
-- Colonnes :
--   channel_id    VARCHAR (PK, format CH-XXXX)
--   channel_name  VARCHAR (E-Commerce Web, Mobile App, In-Store, …)
--   channel_type  VARCHAR (online, physical, phone)
-- SCD : Aucun — dimension statique (5 canaux fixes)
-- ============================================================

-- TODO (S02) : Écrire le CREATE TABLE
--   - PK sur channel_id
--   - 5 lignes canoniques

-- TODO (S02) : Écrire INSERT/SELECT depuis raw_dim_channel
