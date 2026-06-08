-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- fact_order_pipeline -- ACCUMULATING SNAPSHOT (introduite S09)
-- ============================================================
-- GRAIN : une ligne = une commande, mise à jour au fil des jalons.
--
-- Caractéristiques du type accumulating snapshot :
--   - Une ligne par entité (ici : une commande).
--   - Multiple rôles de dates qui se remplissent progressivement
--     (order -> payment -> pick -> ship -> delivery).
--   - Mesures de délai calculées sur place.
--   - UPDATE plutôt qu'INSERT quand un jalon est franchi.
-- ============================================================

CREATE OR REPLACE TABLE fact_order_pipeline AS
SELECT
    rp.pipeline_id,
    rp.order_id,
    CAST(rp.order_date AS DATE)     AS order_date,
    CAST(rp.payment_date AS DATE)   AS payment_date,
    CAST(rp.pick_date AS DATE)      AS pick_date,
    CAST(rp.ship_date AS DATE)      AS ship_date,
    CAST(rp.delivery_date AS DATE)  AS delivery_date,
    rp.current_status,
    CAST(rp.days_order_to_deliver AS INTEGER) AS days_order_to_deliver,
    p.product_key,
    st.store_key,
    c.customer_key,
    -- Flags de jalons atteints (utile pour funnel reports)
    CASE WHEN rp.payment_date IS NOT NULL THEN TRUE ELSE FALSE END AS reached_payment,
    CASE WHEN rp.pick_date IS NOT NULL    THEN TRUE ELSE FALSE END AS reached_pick,
    CASE WHEN rp.ship_date IS NOT NULL    THEN TRUE ELSE FALSE END AS reached_ship,
    CASE WHEN rp.delivery_date IS NOT NULL THEN TRUE ELSE FALSE END AS reached_delivery
FROM raw_fact_order_pipeline rp
JOIN dim_product  p  ON p.product_id = rp.product_id
JOIN dim_store    st ON st.store_id  = rp.store_id
JOIN dim_customer c
  ON c.customer_id = rp.customer_id
 AND CAST(rp.order_date AS DATE) BETWEEN c.effective_from AND c.effective_to;
