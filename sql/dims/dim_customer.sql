-- ============================================================
-- dim_customer.sql — Dimension client (Shared Seeds)
-- ============================================================
-- Grain : 1 ligne = 1 client
-- Source : data/synthetic/team_*/shared/dim_customer.csv
-- Colonnes :
--   customer_id      VARCHAR (PK, format CUS-NNNNN)
--   first_name       VARCHAR
--   last_name        VARCHAR
--   email_domain     VARCHAR (gmail.com, outlook.com, …)
--   city             VARCHAR
--   province         VARCHAR (QC, ON, BC, AB)
--   loyalty_segment  VARCHAR (Platinum, Gold, Silver, Bronze, New, Inactive)
--   join_date        DATE
-- SCD : Candidat principal pour Type 2 (S03)
--        city, province, loyalty_segment changent dans le temps
--        → Ajouter surrogate key, effective_date, end_date, is_current
-- ============================================================

-- TODO (S02) : Écrire le CREATE TABLE (version initiale, natural key)

-- TODO (S03) : Ajouter les colonnes SCD Type 2 :
--   customer_sk    INT (surrogate, PK)
--   effective_date DATE
--   end_date       DATE
--   is_current     BOOLEAN

-- TODO (S02) : Écrire INSERT/SELECT depuis raw_dim_customer
