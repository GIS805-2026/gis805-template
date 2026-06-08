-- DRAFT: à réviser par l'instructeur
-- ============================================================
-- dim_customer -- SCD Type 2 (introduite S02, évoluée en S03)
-- ============================================================
-- Grain : une ligne = une version d'un client.
--
-- Évolution pédagogique
--   S02 : première version (Type 1 -- une ligne par client_id, pas d'historique).
--   S03 : passage en Type 2 -- on ferme les anciennes versions et on en ouvre
--         de nouvelles à chaque changement dans raw_customer_changes.
--
-- La version finale conserve la capacité SCD1 (colonnes non historisées comme
-- email_domain) en parallèle des colonnes historisées (city, province,
-- loyalty_segment).
-- ============================================================

-- Étape 1 : collecter les clients de base + tous les changements historiques.
-- Un client "changer" aura N+1 versions si N changements sont enregistrés.

-- Stratégie : on reconstruit les versions en déroulant chronologiquement
-- les événements de changement sur l'état initial (raw_dim_customer donne
-- l'état au join_date). Chaque changement ouvre une nouvelle version ;
-- les attributs non touchés sont hérités de la version précédente via un
-- LAST_VALUE fenêtré.

CREATE OR REPLACE TABLE dim_customer AS
WITH base AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        email_domain,
        city,
        province,
        loyalty_segment,
        CAST(join_date AS DATE) AS join_date
    FROM raw_dim_customer
),
-- Événements Type 2 uniquement (on ignore les corrections de nom : SCD1).
changes AS (
    SELECT
        customer_id,
        CAST(change_date AS DATE) AS change_date,
        field_changed,
        new_value
    FROM raw_customer_changes
    WHERE field_changed IN ('city', 'province', 'segment')
),
-- Une ligne par (client, point-dans-le-temps) : version 0 au join_date,
-- puis une version additionnelle par événement.
version_points AS (
    SELECT customer_id, join_date AS effective_from, NULL AS field_changed, NULL AS new_value
      FROM base
    UNION ALL
    SELECT customer_id, change_date, field_changed, new_value
      FROM changes
),
-- On porte en avant (LAST_VALUE IGNORE NULLS) la dernière valeur connue
-- de chaque attribut Type 2 jusqu'à la version courante.
rolled AS (
    SELECT
        vp.customer_id,
        vp.effective_from,
        COALESCE(
            LAST_VALUE(CASE WHEN vp.field_changed = 'city' THEN vp.new_value END IGNORE NULLS)
                OVER (PARTITION BY vp.customer_id ORDER BY vp.effective_from
                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
            b.city
        ) AS city,
        COALESCE(
            LAST_VALUE(CASE WHEN vp.field_changed = 'province' THEN vp.new_value END IGNORE NULLS)
                OVER (PARTITION BY vp.customer_id ORDER BY vp.effective_from
                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
            b.province
        ) AS province,
        COALESCE(
            LAST_VALUE(CASE WHEN vp.field_changed = 'segment' THEN vp.new_value END IGNORE NULLS)
                OVER (PARTITION BY vp.customer_id ORDER BY vp.effective_from
                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
            b.loyalty_segment
        ) AS loyalty_segment,
        b.first_name,
        b.last_name,
        b.email_domain,
        ROW_NUMBER() OVER (PARTITION BY vp.customer_id ORDER BY vp.effective_from) AS version_num
    FROM version_points vp
    JOIN base b USING (customer_id)
)
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id, effective_from) AS customer_key,
    customer_id,
    first_name,
    last_name,
    email_domain,
    city,
    province,
    loyalty_segment,
    effective_from,
    COALESCE(
        LEAD(effective_from) OVER (PARTITION BY customer_id ORDER BY effective_from) - INTERVAL 1 DAY,
        DATE '9999-12-31'
    ) AS effective_to,
    LEAD(effective_from) OVER (PARTITION BY customer_id ORDER BY effective_from) IS NULL AS is_current,
    version_num
FROM rolled;

-- Vérifications clés
SELECT 'dim_customer.pk_unique' AS check_name,
       CASE WHEN COUNT(*) = COUNT(DISTINCT customer_key) THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_customer;

SELECT 'dim_customer.has_current_per_customer' AS check_name,
       CASE WHEN COUNT(*) = COUNT(DISTINCT customer_id) THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_customer
WHERE is_current = TRUE;
