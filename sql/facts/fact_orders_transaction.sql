-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- fact_orders_transaction -- TRANSACTION FACT (introduite S09)
-- ============================================================
-- GRAIN : une ligne = une transaction atomique (transaction_id).
--
-- Caractéristiques du type transaction :
--   - Insertion seulement (pas d'update).
--   - Une ligne par événement au moment où il se produit.
--   - Toutes les mesures sont additives.
-- ============================================================

CREATE OR REPLACE TABLE fact_orders_transaction AS
SELECT
    rt.transaction_id,
    CAST(rt.transaction_date AS DATE) AS transaction_date,
    rt.transaction_type,                       -- sale, return, exchange
    p.product_key,
    st.store_key,
    c.customer_key,
    CAST(rt.quantity AS INTEGER)       AS quantity,   -- négatif pour un retour
    CAST(rt.amount AS DECIMAL(10,2))   AS amount
FROM raw_fact_orders_transaction rt
JOIN dim_product  p  ON p.product_id  = rt.product_id
JOIN dim_store    st ON st.store_id   = rt.store_id
JOIN dim_customer c
  ON c.customer_id = rt.customer_id
 AND CAST(rt.transaction_date AS DATE) BETWEEN c.effective_from AND c.effective_to;
