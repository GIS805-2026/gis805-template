-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- fact_budget (introduite S06)
-- ============================================================
-- GRAIN : une ligne = une catégorie × un magasin × un mois.
--
-- Permet le drill-across avec fact_sales sur (store_key, month_key) pour
-- répondre à "réel vs budget par région".
-- ============================================================

CREATE OR REPLACE TABLE fact_budget AS
SELECT
    rb.budget_id,
    CAST(rb.budget_month AS DATE)          AS budget_month,
    rb.category,
    st.store_key,
    CAST(rb.target_revenue AS DECIMAL(12,2)) AS target_revenue,
    CAST(rb.target_units AS INTEGER)       AS target_units
FROM raw_fact_budget rb
JOIN dim_store st ON st.store_id = rb.store_id;
