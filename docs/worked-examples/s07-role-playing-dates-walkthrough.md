# S07 — Role-playing dates, membres inconnus et mini-dimensions

En S07, le CEO veut comprendre **les retards de livraison**. Le problème
est qu'une seule vente produit **plusieurs dates** différentes :
commande, expédition, livraison, retour éventuel. Et parfois, une ou
plusieurs de ces dates sont `NULL` (pas encore expédiée, jamais
livrée). Ce document montre comment modéliser ça proprement.

## La question CEO de S07

> **« Où se produisent les retards de livraison, par date de commande, date d'expédition, date de livraison et géographie ? »**

Trois dates différentes dans la même question. Une seule `dim_date`.
Comment ?

## Étape 1 — Le piège : dupliquer `dim_date`

Première idée naïve : créer `dim_date_order`, `dim_date_ship`,
`dim_date_delivery`. Trois tables, trois fois les mêmes données, trois
fois plus de maintenance, et — surtout — **trois définitions
divergentes** dès que quelqu'un met à jour l'une sans les deux autres.

**Règle.** `dim_date` est **conforme**. On n'en fait pas de copies.

## Étape 2 — Le pattern role-playing

On garde **une seule** `dim_date`, mais on la joint **plusieurs fois**
avec des alias différents.

```sql
SELECT
    f.shipment_id,
    dc.date_iso   AS date_commande,
    de.date_iso   AS date_expedition,
    dl.date_iso   AS date_livraison,
    (dl.date_iso - dc.date_iso)  AS delai_total_jours,
    (de.date_iso - dc.date_iso)  AS delai_prep_jours,
    (dl.date_iso - de.date_iso)  AS delai_transit_jours
FROM fact_shipment f
JOIN dim_date dc ON dc.date_key = f.order_date_key       -- rôle "commande"
JOIN dim_date de ON de.date_key = f.ship_date_key        -- rôle "expédition"
JOIN dim_date dl ON dl.date_key = f.delivery_date_key    -- rôle "livraison"
WHERE dc.year = 2026;
```

**Chaque alias joue un rôle différent** — c'est ça, *role-playing*.
Les trois colonnes de la table de faits (`order_date_key`,
`ship_date_key`, `delivery_date_key`) pointent toutes vers la même
`dim_date`, mais chaque jointure lui donne une sémantique distincte.

## Étape 3 — Gérer les dates manquantes : le membre inconnu

Une commande en préparation n'a pas encore de `ship_date`. Si on laisse
`ship_date_key = NULL`, la jointure `INNER JOIN dim_date` *écarte la
ligne entière*. Le rapport oublie silencieusement toutes les commandes
non expédiées.

**Solution.** On crée une **ligne spéciale** dans `dim_date` pour
« date inconnue » :

| date_key | date_iso   | year | month | quarter | is_unknown |
|---|---|---|---|---|---|
| -1 | 1900-01-01 | 1900 | 1 | 1 | 1 |
| 20260115 | 2026-01-15 | 2026 | 1 | 1 | 0 |

Et on remplace les `NULL` par `-1` au chargement :

```sql
UPDATE fact_shipment
SET ship_date_key = -1
WHERE ship_date_key IS NULL;
```

Maintenant `INNER JOIN` garde la ligne, et le rapport montre
explicitement « expédition : inconnue » au lieu de l'oublier.

**Règle.** Toute FK vers une dimension doit être `NOT NULL`. On remplace
le `NULL` par un membre inconnu. Le test `test_no_null_fks` dans
`validation/checks.sql` enforce cette règle.

## Étape 4 — Hiérarchies géographiques dans `dim_store`

Le CEO demande aussi « par géographie ». Il veut pouvoir descendre :
province → région → district → magasin. Si on garde ces quatre niveaux
**dans une seule `dim_store`** (snowflake évité), le drill-down devient
un simple `GROUP BY` :

```sql
SELECT s.province, s.region, s.district,
       COUNT(*)                             AS nb_commandes,
       AVG(delai_total_jours)               AS delai_moyen
FROM fact_shipment f
JOIN dim_store s ON s.store_key = f.store_key
JOIN dim_date  dc ON dc.date_key = f.order_date_key
WHERE dc.year = 2026
GROUP BY GROUPING SETS (
  (s.province),                     -- total par province
  (s.province, s.region),           -- par région
  (s.province, s.region, s.district) -- par district
);
```

`GROUPING SETS` produit les trois niveaux d'agrégation en une seule
passe. Le rapport exécutif s'affiche directement.

## Étape 5 — Mini-dimension : quand un attribut change trop vite

`dim_customer` contient des attributs stables (nom, ville, segment) et
des attributs qui changent *à chaque interaction* : taux d'ouverture
d'email, score NPS, bande de dépense récente. Si on met ces derniers
dans `dim_customer` en SCD2, la dimension explose.

**Solution.** On crée une **mini-dimension** `dim_customer_activity`
qui contient *toutes les combinaisons possibles* des attributs
volatiles, avec sa propre clé.

| activity_key | email_open_rate_band | nps_band | spend_band |
|---|---|---|---|
| 1 | low    | detractor | low    |
| 2 | medium | neutral   | medium |
| 3 | high   | promoter  | high   |

Dans `fact_sales`, on ajoute `activity_key` *au moment de la vente*.
`dim_customer` reste stable et lisible ; la mini-dim absorbe la
volatilité.

```sql
-- Quel segment était actif au moment de la vente ?
SELECT c.full_name,
       a.nps_band,
       a.spend_band,
       SUM(f.line_total) AS revenue
FROM fact_sales f
JOIN dim_customer          c ON c.customer_key  = f.customer_key
JOIN dim_customer_activity a ON a.activity_key  = f.activity_key
GROUP BY c.full_name, a.nps_band, a.spend_band;
```

**Règle.** Mini-dim quand l'attribut change plusieurs fois par trimestre
et n'a de valeur qu'**au moment de l'événement**.

## Diagramme synthétique

```mermaid
flowchart LR
  F[fact_shipment] -->|order_date_key|    DC[dim_date<br/>rôle commande]
  F -->|ship_date_key|                    DE[dim_date<br/>rôle expedition]
  F -->|delivery_date_key|                DL[dim_date<br/>rôle livraison]
  F -->|store_key| S[dim_store<br/>hierarchie 4 niveaux]
  F -->|activity_key| A[dim_customer_activity<br/>mini-dim]
  F -->|customer_key| C[dim_customer<br/>stable, SCD2]
  DC -.same table.-> DE
  DE -.same table.-> DL
```

Trois alias pointent vers **la même** `dim_date`. Une mini-dim absorbe
les attributs volatiles. `dim_customer` reste propre.

## Votre livrable S07

`answers/S07_executive_brief.md` doit :

1. Une requête avec **trois** alias de `dim_date` nommés lisiblement
   (`dc`, `de`, `dl`) et **une** mesure de délai calculée.
2. Un paragraphe qui explique pourquoi dupliquer `dim_date` en
   `dim_date_ship` serait une erreur de gouvernance.
3. Un exemple concret de ligne avec `ship_date_key = -1` (membre
   inconnu) et ce que le rapport affiche pour elle.
4. Un attribut volatile que vous **auriez pu** mettre dans
   `dim_customer` et que vous préférez en mini-dim — avec la raison.

Templates SQL pertinents : `sql/templates/02_fact_with_grain.sql` (pour
le fait) et `sql/templates/01_dim_from_raw.sql` (pour la dimension
et son membre inconnu).
