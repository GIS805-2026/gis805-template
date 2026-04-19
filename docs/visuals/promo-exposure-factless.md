# Factless fact table : mesurer ce qui s'est produit — ou ne s'est pas produit

Une **factless fact table** n'a aucune mesure numérique. Elle enregistre
qu'**un événement s'est produit** — rien d'autre. Contre-intuitif,
mais c'est exactement ce qu'il faut pour répondre à toute une famille
de questions qu'aucune autre structure ne peut répondre.

## Le cas NexaMart : exposition publicitaire

Le marketing lance une campagne. Chaque fois qu'un client voit une pub
d'un produit via un canal, on enregistre **un événement** :

- QUI (client)
- QUOI (produit en vedette)
- QUAND (date)
- OÙ (canal : email, web, app, magasin)
- DANS QUEL CONTEXTE (campagne active)

**Rien à mesurer.** Il n'y a pas de montant, pas de quantité. L'événement
lui-même **est** l'information.

## Structure

```text
fact_promo_exposure  (aucune colonne de mesure)
┌──────────────┬─────────────┬─────────────┬──────────────────┬──────────────┐
│ customer_key │ product_key │campaign_key │ exposure_date_key│ channel_key  │
├──────────────┼─────────────┼─────────────┼──────────────────┼──────────────┤
│          42  │        128  │         7   │      20260115    │           2  │  email
│          42  │        128  │         7   │      20260116    │           3  │  app
│          42  │         55  │         7   │      20260116    │           2  │  email
│          18  │        128  │         7   │      20260117    │           1  │  web
│          91  │        128  │         8   │      20260120    │           2  │  email
└──────────────┴─────────────┴─────────────┴──────────────────┴──────────────┘
```

Cinq clés étrangères, zéro mesure. Chaque ligne dit "cette personne a
été exposée à ce produit via ce canal, ce jour-là, pendant cette
campagne". Point.

## Deux familles de questions qu'elle répond

### Famille 1 — Couverture (comptage d'événements)

```text
┌────────────────────────────────────────────────────────┐
│  "Combien de clients a-t-on touchés par la campagne ?" │
└────────────────────────────────────────────────────────┘

SELECT COUNT(DISTINCT customer_key) AS clients_exposes
FROM fact_promo_exposure
WHERE campaign_key = 7;
```

```text
┌─────────────────────────────────────────────────────────────┐
│  "Fréquence d'exposition moyenne par client pendant la      │
│   campagne 7 ?"                                             │
└─────────────────────────────────────────────────────────────┘

SELECT AVG(nb_expositions) AS freq_moyenne
FROM (
  SELECT customer_key, COUNT(*) AS nb_expositions
  FROM fact_promo_exposure
  WHERE campaign_key = 7
  GROUP BY customer_key
);
```

### Famille 2 — Absence (anti-join, la plus précieuse)

```text
┌──────────────────────────────────────────────────────────────┐
│  "Quels produits en promotion N'ONT reçu AUCUNE exposition  │
│   cette semaine ?"   ← impossible à répondre sans factless   │
└──────────────────────────────────────────────────────────────┘

SELECT p.product_name
FROM dim_product      p
JOIN dim_campaign     c ON c.status = 'active'
LEFT JOIN fact_promo_exposure e
       ON e.product_key  = p.product_key
      AND e.campaign_key = c.campaign_key
      AND e.exposure_date_key BETWEEN 20260115 AND 20260121
WHERE e.customer_key IS NULL;        -- ← le produit n'apparaît nulle part
```

Sans factless, cette question est **non répondable**. Il faudrait
inventer une "vente de 0 $" ou un événement fictif — deux manières
d'introduire des données mensongères.

## Visuel : les deux usages

```text
                    ┌─────────────────────────┐
                    │  fact_promo_exposure    │
                    │  (aucune mesure)        │
                    └────────────┬────────────┘
                                 │
           ┌─────────────────────┼─────────────────────┐
           │                     │                     │
           ▼                     ▼                     ▼
    ╔══════════════╗      ╔══════════════╗      ╔══════════════╗
    ║  COUNT(*)    ║      ║  COUNT       ║      ║  LEFT JOIN   ║
    ║              ║      ║  DISTINCT    ║      ║  ... IS NULL ║
    ║  "combien    ║      ║  customer    ║      ║  "qui est    ║
    ║  d'événe-    ║      ║  "qui a été  ║      ║  absent ?"   ║
    ║  ments ?"    ║      ║  touché ?"   ║      ║              ║
    ╚══════════════╝      ╚══════════════╝      ╚══════════════╝
       couverture            portée unique         GAP ANALYSIS
```

## Factless vs les trois autres types

```text
                         mesure      UPDATE     question typique
                         numérique   autorisé ? répondue
┌───────────────────────┬───────────┬──────────┬───────────────────────┐
│ Transaction           │   OUI     │   non    │ "combien vendu ?"     │
│ Periodic Snapshot     │   OUI     │   non    │ "stock au 31/03 ?"    │
│ Accumulating Snapshot │   OUI     │   OUI    │ "délai moyen ?"       │
│ Factless              │   NON     │   non    │ "qui a été exposé ?"  │
│                       │           │          │ "qui est absent ?"    │
└───────────────────────┴───────────┴──────────┴───────────────────────┘
```

## Piège classique

### "J'ajoute `event_count = 1` pour avoir une mesure"

C'est techniquement toléré et ça ne casse rien. Mais ça signale que
vous n'avez pas compris la valeur de la factless : toute la puissance
vient de `COUNT(*)` (qui ne nécessite aucune colonne) et des anti-joins
(qui s'intéressent à l'**absence**, pas aux valeurs).

Garder la table réellement *factless* documente l'intention : ce
processus n'a pas de quantité intrinsèque.

## Conversion d'attribution : lier factless et fact_sales

Question business réaliste :

> "Parmi les clients exposés à la campagne 7, quel pourcentage a acheté le produit 128 dans les 14 jours suivants ?"

```sql
WITH exposed AS (
  SELECT DISTINCT customer_key, exposure_date_key
  FROM fact_promo_exposure
  WHERE campaign_key = 7 AND product_key = 128
),
converted AS (
  SELECT DISTINCT e.customer_key
  FROM exposed e
  JOIN fact_sales  s ON s.customer_key  = e.customer_key
                    AND s.product_key   = 128
                    AND s.order_date BETWEEN e.exposure_date_key
                                         AND e.exposure_date_key + 14
)
SELECT
  (SELECT COUNT(*) FROM converted) * 100.0 /
  (SELECT COUNT(*) FROM exposed) AS conversion_pct;
```

La factless fournit la **liste des exposés** ; la transaction fournit
la **liste des acheteurs** ; la comparaison donne le taux de conversion.
**Aucun autre couple de tables ne peut produire ce chiffre.**

## À retenir

1. Factless = événement **sans mesure numérique**.
2. Sa valeur : répondre aux questions de **couverture** et surtout
   d'**absence** (anti-join).
3. Ne pas ajouter de mesure "pour faire bien" — ça brouille l'intention.
4. Combinée à une transaction, elle ouvre l'**analyse de conversion**
   que personne d'autre ne peut offrir.

Le worked example complet des quatre types de faits est dans
`docs/worked-examples/s09-four-fact-types-walkthrough.md`. Le code
de référence est dans
`content/courses/GIS805/reference-solution/sql/facts/fact_promo_exposure.sql`.
