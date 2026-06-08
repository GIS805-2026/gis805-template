-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- fact_sales (introduite S02, évoluée en S04, S06)
-- ============================================================
-- GRAIN : une ligne = une ligne de commande (sale_line_id).
--
-- Évolution
--   S02 : version minimale, jointures vers 5 dimensions conformées.
--   S03 : les jointures vers dim_customer utilisent maintenant la version
--         SCD2 (on résout la version active à la date de la commande).
--   S04 : ajout de order_number (dim dégénérée) + profile_key (junk dim).
--   S06 : rechargement avec volume plus élevé, même structure.
-- ============================================================

CREATE OR REPLACE TABLE fact_sales AS
SELECT
    rs.sale_line_id,                       -- PK, grain
    rs.order_number,                        -- dimension dégénérée (S04)
    CAST(rs.order_date AS DATE) AS order_date,
    -- Clés étrangères substitut (surrogate)
    c.customer_key,
    p.product_key,
    st.store_key,
    ch.channel_key,
    dop.profile_key,                        -- junk dim FK (S04); NULL si commande hors S04
    -- Mesures additives
    CAST(rs.quantity AS INTEGER)            AS quantity,
    CAST(rs.unit_price AS DECIMAL(10,2))    AS unit_price,
    CAST(rs.discount_pct AS DECIMAL(5,2))   AS discount_pct,
    CAST(rs.net_price AS DECIMAL(10,2))     AS net_price,
    CAST(rs.line_total AS DECIMAL(10,2))    AS line_total,
    -- Mesure dérivée : marge
    CAST((rs.net_price - p.unit_cost) * rs.quantity AS DECIMAL(10,2))
        AS margin_amount
FROM raw_fact_sales rs
-- Résolution SCD2 : on prend la version de dim_customer active à la date
-- de la commande, pas la version courante.
JOIN dim_customer c
  ON c.customer_id = rs.customer_id
 AND CAST(rs.order_date AS DATE) BETWEEN c.effective_from AND c.effective_to
JOIN dim_product p  ON p.product_id = rs.product_id
JOIN dim_store   st ON st.store_id  = rs.store_id
JOIN dim_channel ch ON ch.channel_id = rs.channel_id
-- S04 : résolution de la junk dimension via raw_orders (LEFT pour ne pas
-- perdre les lignes S06 qui n'ont pas de correspondance dans raw_orders)
LEFT JOIN raw_orders ro ON ro.order_number = rs.order_number
LEFT JOIN dim_order_profile dop
       ON dop.is_gift_wrapped      = ro.is_gift_wrapped
      AND dop.is_express_shipping  = ro.is_express_shipping
      AND dop.is_loyalty_redeemed  = ro.is_loyalty_redeemed
      AND dop.is_promo_applied     = ro.is_promo_applied
      AND dop.is_employee_purchase = ro.is_employee_purchase
      AND dop.is_online_pickup     = ro.is_online_pickup
      AND dop.is_fragile           = ro.is_fragile
      AND dop.is_oversized         = ro.is_oversized;

-- Vérification de grain
SELECT 'fact_sales.grain_unique' AS check_name,
       CASE WHEN COUNT(*) = COUNT(DISTINCT sale_line_id) THEN 'PASS' ELSE 'FAIL' END AS result
FROM fact_sales;

-- Vérification d'orphelin (toutes les FK résolvent)
SELECT 'fact_sales.no_orphan_customer' AS check_name,
       CASE WHEN COUNT(*) FILTER (WHERE customer_key IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM fact_sales;
