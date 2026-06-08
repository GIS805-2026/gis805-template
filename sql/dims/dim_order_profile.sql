-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- dim_order_profile -- junk dimension (introduite S04)
-- ============================================================
-- Grain : une ligne = une combinaison distincte de drapeaux opérationnels.
--
-- Les 8 drapeaux booléens de raw_orders ne méritent pas chacun leur propre
-- dimension (cardinalité 2, valeurs sans contexte business riche). On les
-- consolide dans une junk dimension qui stocke seulement les combinaisons
-- effectivement observées.
-- ============================================================

CREATE OR REPLACE TABLE dim_order_profile AS
WITH distinct_combos AS (
    SELECT DISTINCT
        is_gift_wrapped,
        is_express_shipping,
        is_loyalty_redeemed,
        is_promo_applied,
        is_employee_purchase,
        is_online_pickup,
        is_fragile,
        is_oversized
    FROM raw_orders
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            is_gift_wrapped, is_express_shipping, is_loyalty_redeemed,
            is_promo_applied, is_employee_purchase, is_online_pickup,
            is_fragile, is_oversized
    )                                     AS profile_key,
    is_gift_wrapped,
    is_express_shipping,
    is_loyalty_redeemed,
    is_promo_applied,
    is_employee_purchase,
    is_online_pickup,
    is_fragile,
    is_oversized,
    -- Libellé humain pour requêtes ad hoc
    CASE
        WHEN is_gift_wrapped AND is_fragile THEN 'Cadeau fragile'
        WHEN is_express_shipping AND is_oversized THEN 'Express gros volume'
        WHEN is_loyalty_redeemed AND is_promo_applied THEN 'Fidélité + promo'
        WHEN is_employee_purchase THEN 'Achat employé'
        WHEN is_online_pickup THEN 'Click and collect'
        ELSE 'Standard'
    END                                    AS profile_label
FROM distinct_combos;
