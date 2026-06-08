-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- stg_customer_conformed (introduite S06)
-- ============================================================
-- Consolide les clients mentionnés dans les différents systèmes sources
-- en une liste unique avec customer_id comme clé naturelle canonique.
--
-- Utilité : quand plusieurs faits (fact_sales, fact_returns, fact_shipment)
-- arrivent avec des conventions de clés légèrement différentes, on passe
-- par cette vue pour conformer.
-- ============================================================

CREATE OR REPLACE VIEW stg_customer_conformed AS
SELECT DISTINCT
    customer_id,
    first_name,
    last_name,
    email_domain,
    city,
    province,
    loyalty_segment,
    join_date
FROM raw_dim_customer
WHERE customer_id IS NOT NULL;
