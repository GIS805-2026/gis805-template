# S09 — Les quatre types de tables de faits

Kimball décrit **quatre** types de tables de faits. Chacun résout un
problème différent. En choisir un au hasard produit soit des chiffres
faux, soit des rapports impossibles à écrire. Ce document prend la
carte des processus NexaMart et montre quand utiliser chaque type —
avec un exemple grandeur nature de la reference-solution.

## La question CEO de S09

> **« Quels processus NexaMart sont transactionnels, quels sont des snapshots, et quels sont de simples présences ? »**

Le CEO veut un **inventaire typé** des processus, pas une collection de
tables au hasard.

## Type 1 — Table de faits transactionnelle (*transaction*)

**Une ligne = un événement discret à un instant donné.**

- Grain le plus fin possible.
- Mesures additives (on peut sommer sur n'importe quel axe).
- Pas de mise à jour : on insère, jamais on ne corrige.

Exemple NexaMart : `fact_orders_transaction`

```sql
CREATE TABLE fact_orders_transaction AS
SELECT
    o.order_transaction_id,    -- grain : un événement commande
    o.customer_key,
    o.store_key,
    o.order_date,
    o.event_type,               -- "created", "paid", "cancelled"
    o.amount
FROM raw_order_events o;
```

Questions naturellement répondues : "combien de commandes par jour ?",
"revenu par canal et par trimestre ?", "taux d'annulation par
magasin ?". C'est le type **par défaut** pour tout processus
événementiel.

**Attention.** Plus le grain est fin, plus la table est grande. Ce
n'est pas un problème en soi — DuckDB et les bases analytiques
modernes gèrent des milliards de lignes. Mais ne dénormalisez pas les
attributs de dimension dans le fait pour "économiser" une jointure.

## Type 2 — Snapshot périodique (*periodic snapshot*)

**Une ligne = l'état d'une entité à une date figée.**

- Grain = (entité, date).
- Mesures **semi-additives** : on peut sommer sur tout, **sauf** le
  temps. Un stock de 500 le 1er + un stock de 500 le 2 ne fait pas 1000.
- Insert-only aussi, mais avec un enregistrement périodique (jour,
  semaine, mois).

Exemple NexaMart : `fact_inventory_snapshot`

```sql
CREATE TABLE fact_inventory_snapshot AS
SELECT
    product_key,
    store_key,
    snapshot_date,              -- une ligne par (produit, magasin, jour)
    units_on_hand,              -- semi-additif
    units_on_order,
    reorder_point
FROM raw_inventory_snapshot;
```

Rapports typiques : "stock moyen du mois par catégorie" (moyenne sur
les jours, somme sur les catégories), "jours de rupture par magasin".

**Règle semi-additivité.** Si vous sommez `units_on_hand` sur plusieurs
jours, vous obtenez un chiffre absurde (appelé *sum fallacy*). Utilisez
`AVG` ou bien la valeur du **dernier jour** de la période :

```sql
-- Stock moyen mensuel par catégorie : correct
SELECT p.category, d.year_month,
       AVG(i.units_on_hand) AS stock_moyen
FROM fact_inventory_snapshot i
JOIN dim_product p ON p.product_key = i.product_key
JOIN dim_date    d ON d.date_key    = i.snapshot_date
GROUP BY p.category, d.year_month;
```

## Type 3 — Snapshot accumulating (*accumulating snapshot*)

**Une ligne = un pipeline qui progresse dans le temps.**

- Grain = une instance du processus.
- Plusieurs **date keys** : une par étape (commande, expédition,
  livraison, retour).
- **Mise à jour** au fil de l'avancement. C'est le seul type où
  l'`UPDATE` est normal.

Exemple NexaMart : `fact_order_pipeline`

```sql
CREATE TABLE fact_order_pipeline AS
SELECT
    order_id,                   -- grain : une commande
    customer_key,
    product_key,
    order_date_key,             -- étape 1
    paid_date_key,              -- étape 2  (NULL si pas encore payé)
    ship_date_key,              -- étape 3
    deliver_date_key,           -- étape 4
    return_date_key,            -- étape 5  (NULL la plupart du temps)
    order_to_ship_days,         -- lag calculé (lazy-computed)
    ship_to_deliver_days,
    total_cycle_days
FROM raw_order_pipeline;
```

Lorsqu'une commande passe de "payée" à "expédiée", on fait un `UPDATE`
sur la ligne pour remplir `ship_date_key` et recalculer les lags. C'est
la seule table de faits où ça se fait.

Questions naturellement répondues : "délai moyen commande→livraison",
"combien de commandes stagnent en préparation depuis > 7 jours ?",
"taux de retour par délai de livraison".

**Dates manquantes.** Chaque étape non franchie a sa FK à `-1` (membre
inconnu — voir S07). Jamais de `NULL`.

## Type 4 — Table de faits *factless* (présence / couverture)

**Une ligne = un événement qui s'est produit, sans mesure numérique.**

- Pas de mesure additive.
- On compte des **occurrences** ou on teste des **absences**.

Exemple NexaMart : `fact_promo_exposure`

```sql
CREATE TABLE fact_promo_exposure AS
SELECT
    customer_key,
    campaign_key,
    product_key,
    exposure_date_key,
    channel_key                  -- comment le client a été exposé
    -- AUCUNE mesure numérique : l'exposition s'est produite, point.
FROM raw_promo_exposure;
```

Deux familles de questions qu'un *factless* répond :

1. **Couverture.** "Combien de clients ont été exposés à la campagne
   X ?" → `COUNT(DISTINCT customer_key)`.
2. **Absence.** "Quels produits en promotion n'ont reçu aucune
   exposition cette semaine ?" → anti-join avec `dim_product`.

```sql
-- Produits promus mais jamais exposés cette semaine
SELECT p.product_name
FROM dim_product p
JOIN dim_campaign c ON c.status = 'active'
LEFT JOIN fact_promo_exposure e
       ON e.product_key  = p.product_key
      AND e.campaign_key = c.campaign_key
      AND e.exposure_date_key BETWEEN :week_start AND :week_end
WHERE e.customer_key IS NULL;
```

Sans le factless, cette question ne peut **pas** être répondue : il n'y
a pas d'événement transactionnel à interroger.

## Arbre de décision

```mermaid
flowchart TD
  Q[Quel processus ?] --> Q1{Événement<br/>discret<br/>ponctuel ?}
  Q1 -->|oui|                  T1[Transaction]
  Q1 -->|non|                  Q2{État à une<br/>date fixe ?}
  Q2 -->|oui|                  T2[Periodic Snapshot<br/>semi-additif]
  Q2 -->|non|                  Q3{Pipeline qui<br/>progresse ?}
  Q3 -->|oui|                  T3[Accumulating Snapshot<br/>UPDATE autorisé]
  Q3 -->|non|                  Q4{Événement<br/>sans mesure ?}
  Q4 -->|oui|                  T4[Factless<br/>presence/coverage]
```

## Erreurs fréquentes à déjouer

### « J'ai sommé `units_on_hand` sur le mois »

Vous avez additionné 30 fois le stock. Utilisez `AVG` ou la valeur de
fin de période.

### « J'ai fait un INSERT à chaque étape du pipeline »

Vous avez 4 lignes par commande et le grain est cassé. C'est un
accumulating snapshot : une ligne par commande, mise à jour au fil des
étapes.

### « J'ai ajouté `event_count = 1` dans ma factless »

C'est techniquement une mesure et c'est OK, mais ne vous y attachez
pas : toute la valeur vient de `COUNT(*)` et des anti-joins. Garder la
table réellement factless clarifie l'intention.

## Votre livrable S09

`answers/S09_executive_brief.md` doit :

1. Classifier **les 4 processus NexaMart vus jusqu'ici**
   (commandes, inventaire, pipeline de livraison, exposition promo)
   dans les 4 types de faits. Un tableau suffit.
2. Pour **chacun**, une requête représentative (1 SQL par type).
3. Un exemple de **mauvaise** modélisation (ex. snapshot d'inventaire
   stocké comme transaction) et ce que ça casse dans les rapports.
4. Un cas où une factless permet une question qu'aucun autre type ne
   peut répondre (indice : absence).

Templates SQL : `sql/templates/02_fact_with_grain.sql` couvre la
transaction ; les trois autres types sont démontrés dans
`content/courses/GIS805/reference-solution/sql/facts/` — lisez
`fact_inventory_snapshot.sql`, `fact_order_pipeline.sql` et
`fact_promo_exposure.sql` pour voir le code complet.
