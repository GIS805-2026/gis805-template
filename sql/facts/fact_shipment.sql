-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- fact_shipment (introduite S07)
-- ============================================================
-- GRAIN : une ligne = une expédition (shipment_id).
--
-- Démontre trois patterns S07 :
--   1. Role-playing dates : order_date, ship_date, delivery_date pointent
--      toutes vers dim_date mais avec des alias différents en requête.
--   2. NULLs intentionnels : delivery_date peut être NULL (in_transit) ;
--      carrier peut être NULL (inconnu) -- on le remplace par "Unknown".
--   3. Hiérarchie géographique : destination via dim_geography.
-- ============================================================

CREATE OR REPLACE TABLE fact_shipment AS
SELECT
    rs.shipment_id,
    CAST(rs.order_date AS DATE)            AS order_date,
    CAST(rs.ship_date AS DATE)             AS ship_date,
    CAST(rs.delivery_date AS DATE)         AS delivery_date,  -- peut être NULL
    p.product_key,
    st.store_key,
    c.customer_key,
    ch.channel_key,
    -- carrier : member explicite 'Unknown' plutôt que NULL pour simplifier
    -- les GROUP BY downstream.
    COALESCE(rs.carrier, 'Unknown')        AS carrier,
    g.geography_key                         AS destination_geography_key,
    rs.delivery_status,
    CAST(rs.shipping_cost AS DECIMAL(10,2)) AS shipping_cost,
    -- Mesures dérivées de rôles de dates (NULL si toujours en transit)
    CASE
        WHEN rs.delivery_date IS NOT NULL
        THEN CAST(rs.delivery_date AS DATE) - CAST(rs.order_date AS DATE)
    END                                     AS days_order_to_delivery,
    CASE
        WHEN rs.delivery_date IS NOT NULL
        THEN CAST(rs.delivery_date AS DATE) - CAST(rs.ship_date AS DATE)
    END                                     AS days_ship_to_delivery
FROM raw_fact_shipment rs
JOIN dim_product   p  ON p.product_id = rs.product_id
JOIN dim_store     st ON st.store_id  = rs.store_id
-- Pour la version SCD2 de dim_customer, on prend la version active à la
-- date de la commande (pas de la livraison).
JOIN dim_customer  c
  ON c.customer_id = rs.customer_id
 AND CAST(rs.order_date AS DATE) BETWEEN c.effective_from AND c.effective_to
JOIN dim_channel   ch ON ch.channel_id = rs.channel_id
LEFT JOIN dim_geography g ON g.city = rs.destination_city;
