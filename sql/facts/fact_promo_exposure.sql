-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- fact_promo_exposure -- FACTLESS FACT (introduite S09)
-- ============================================================
-- GRAIN : une ligne = un client × une campagne × une date d'exposition.
--
-- Caractéristiques du type factless :
--   - Aucune mesure quantitative : la présence de la ligne EST l'information.
--   - Réponse typique : "combien de clients exposés ?",
--     "quelle couverture par segment ?".
--   - Si vous ajoutez une mesure (ex. coût d'impression), ce n'est plus
--     factless -- c'est un fait transactionnel avec exposure_cost.
-- ============================================================

CREATE OR REPLACE TABLE fact_promo_exposure AS
SELECT
    re.exposure_id,
    CAST(re.exposure_date AS DATE)  AS exposure_date,
    re.campaign_id,                        -- dimension dégénérée (ou joint vers dim_campaign)
    c.customer_key,
    ch.channel_key
FROM raw_fact_promo_exposure re
JOIN dim_customer c
  ON c.customer_id = re.customer_id
 AND CAST(re.exposure_date AS DATE) BETWEEN c.effective_from AND c.effective_to
JOIN dim_channel ch ON ch.channel_id = re.channel_id;
