-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- dim_product (introduite S02)
-- ============================================================
-- Grain : une ligne = un produit au catalogue.
-- ============================================================

CREATE OR REPLACE TABLE dim_product AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_key,   -- clé substitut
    product_id,                                                -- clé naturelle
    product_name,
    category,
    subcategory,
    brand,
    CAST(unit_cost AS DECIMAL(10,2))       AS unit_cost,
    CAST(unit_price AS DECIMAL(10,2))      AS unit_price,
    CAST(unit_price - unit_cost AS DECIMAL(10,2)) AS unit_margin,
    CURRENT_DATE                           AS loaded_at
FROM raw_dim_product
WHERE product_id IS NOT NULL;
