-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- fact_returns (introduite S06)
-- ============================================================
-- GRAIN : une ligne = une ligne de retour (return_id).
-- Dimensions conformées : product, store, date (return_date), customer.
--
-- Design note : on NE joint PAS directement fact_sales ici (règle d'or :
-- un fait ne dépend pas d'un autre fait au moment du build). On résout le
-- customer_key SCD2 via raw_fact_sales + dim_customer en une seule
-- passe -- ce qui permet aussi à ce fichier de s'exécuter avant ou après
-- fact_sales.sql dans l'ordre alphabétique de run_pipeline.py.
-- ============================================================

CREATE OR REPLACE TABLE fact_returns AS
WITH sale_context AS (
    -- Récupère le order_date et le customer_id depuis la vente d'origine
    -- (raw, pas fact_sales) pour résoudre la version SCD2 active.
    SELECT
        rs.sale_line_id,
        CAST(rs.order_date AS DATE) AS original_order_date,
        rs.customer_id              AS original_customer_id
    FROM raw_fact_sales rs
)
SELECT
    rr.return_id,
    rr.original_sale_line_id,
    CAST(rr.return_date AS DATE)            AS return_date,
    p.product_key,
    st.store_key,
    c.customer_key,                          -- version SCD2 active à la date de vente
    CAST(rr.return_quantity AS INTEGER)     AS return_quantity,
    CAST(rr.refund_amount AS DECIMAL(10,2)) AS refund_amount,
    rr.return_reason
FROM raw_fact_returns rr
JOIN dim_product  p  ON p.product_id = rr.product_id
JOIN dim_store    st ON st.store_id  = rr.store_id
LEFT JOIN sale_context sc ON sc.sale_line_id = rr.original_sale_line_id
LEFT JOIN dim_customer c
  ON c.customer_id = sc.original_customer_id
 AND sc.original_order_date BETWEEN c.effective_from AND c.effective_to;
