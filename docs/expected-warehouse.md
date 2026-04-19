# État attendu de l'entrepôt, session par session

Ce document liste les tables `dim_*` et `fact_*` que votre base
`db/nexamart.duckdb` devrait contenir à la fin de chaque session, avec des
fourchettes de cardinalité. Les chiffres exacts varient selon votre
`team_seed` — utilisez les fourchettes comme garde-fou, pas comme cible
absolue.

## Comment lire ce document

Après `make load`, la commande `python src/run_pipeline.py` affiche un
résumé de vos tables. Comparez à la colonne *"lignes attendues"* ci-dessous.

Pour un check automatique, `make check` exécute `validation/checks.sql`
qui vérifie la présence, la cardinalité minimale, l'unicité des clés,
et l'absence de NULLs dans les FK.

---

## Après S02 — Étoile & grain

| Table | Lignes attendues | Notes |
|---|---|---|
| `dim_date` | 730 (2024-01-01 → 2025-12-31) | Généré par `gen_shared_seeds.py` |
| `dim_product` | 40-70 | Subset équipe-spécifique du master catalog |
| `dim_store` | 10 | Canonique, identique pour toutes les équipes |
| `dim_channel` | 5 | Canonique |
| `dim_customer` | 150-400 | Subset équipe-spécifique |
| `fact_sales` | 1 200-10 000 | ~ `n_orders × avg_lines` |

**`make check` attendu :** tous les `TABLE_EXISTS`, `ROW_COUNT`, `PK_UNIQUE`
et `FK_NOT_NULL` en PASS. Les checks S06/S08 sont en SKIP (commentés).

**Votre brief** doit citer au moins une requête agrégeant `fact_sales`
jointe à 2+ dimensions pour répondre à la question CEO de la semaine.

---

## Après S03 — SCD Type 2

| Table | Lignes attendues | Notes |
|---|---|---|
| `dim_customer` | 150-400 + historique | Type 2 : chaque changement ajoute une ligne |
| `dim_customer_scd2` ou équivalent | > `dim_customer` initial | Colonnes `effective_from`, `effective_to`, `is_current` |
| Autres tables S02 | inchangées | Le grain de `fact_sales` reste identique |

Le nombre de versions dépend de votre `team_seed` (15-45 % des clients
changent, 1 à 4 changements chacun).

**Votre brief** doit montrer un rapport AVANT/APRÈS illustrant comment
Type 1 cacherait l'historique et Type 2 le préserve.

---

## Après S04 — Dimensions dégénérées + junk

| Table | Lignes attendues | Notes |
|---|---|---|
| `dim_order_profile` (junk) | ≤ 2⁸ = 256 | Combinaisons distinctes des 8 drapeaux |
| `fact_orders` ou `fact_sales_enriched` | 300-800 | `order_number` reste colonne (degenerate) |
| `fact_order_lines` | 300-5 600 | Un par ligne de commande |

La junk dimension ne contient **que** les combinaisons observées — si
aucune commande n'a `is_fragile=1 AND is_oversized=1 AND is_gift_wrapped=1`,
cette ligne n'existe pas.

**Votre brief** doit analyser au moins une paire de drapeaux corrélés
(ex. `is_promo_applied` × `is_loyalty_redeemed`).

---

## Après S06 — Intégration entreprise

| Table | Lignes attendues | Notes |
|---|---|---|
| `fact_sales` | 1 500-4 000 | Rechargé avec les données S06 |
| `fact_returns` | 75-720 | 5-18 % de `fact_sales` |
| `fact_inventory_snapshot` | ~8 000-16 000 | Hebdomadaire × produit × magasin |
| `fact_budget` | 1 200 | 10 catégories × 10 magasins × 12 mois |

**`make check` attendu :** décommentez le check `RECONCILE`
(section 6 de `validation/checks.sql`) qui compare `SUM(line_total)` de
`fact_sales` avec `SUM(target_revenue)` de `fact_budget`. La variance
dépend de votre bias équipe (0.8× à 1.3×) — un écart < 200 % est normal.

**Votre brief** doit produire un rapport réel-vs-budget par région
(drill-across via `dim_store`).

---

## Après S07 — Dimensions spéciales

| Table | Lignes attendues | Notes |
|---|---|---|
| `fact_shipment` | 600-2 000 | Dates à rôles (order/ship/delivery) |
| `dim_geography` | 10-20 | Villes uniques entre magasins et clients |
| `dim_customer_profile` (mini) | = `dim_customer` | Tranches d'âge, dépense, fréquence |

La table `fact_shipment` contient des NULLs intentionnels (carrier, delivery_date)
à taux variable selon l'équipe (5-25 % pour carrier, 8-30 % pour delivery).

**Votre brief** doit documenter votre politique NULL (ex. introduction
d'un membre `dim_carrier` "Inconnu" vs. laisser NULL).

---

## Après S08 — Ponts pondérés & SCD3

| Table | Lignes attendues | Notes |
|---|---|---|
| `bridge_customer_segment` | `n_customers × 1.2-2.5` | `SUM(weight) = 1.0` par client |
| `bridge_campaign_allocation` | 8-32 | 8 campagnes × 1-4 segments ciblés |
| `dim_customer_scd3` | = `n_customers` | `current_segment` + `previous_segment` |
| `dim_segment_outrigger` | 6 | Un par segment |

**`make check` attendu :** décommentez le check `BRIDGE_WEIGHT`
(section 7) qui vérifie `SUM(weight) = 1.0 ± 0.01` par client.

**Votre brief** doit inclure deux rapports : sans pont (appartenance
unique) et avec pont (appartenance pondérée). La différence motive le pont.

---

## Après S09 — Quatre types de faits

| Table | Type | Lignes attendues |
|---|---|---|
| `fact_orders_transaction` | Transaction | 800-2 500 |
| `fact_daily_inventory` | Periodic snapshot | 1 500 (10 produits × 5 magasins × 30 jours) |
| `fact_order_pipeline` | Accumulating snapshot | 300-800 |
| `fact_promo_exposure` | Factless | 800-5 500 (selon taux d'exposition) |

**Votre brief** doit expliquer pourquoi un type de faits convient à un
processus donné et pas un autre (ex. pourquoi ne pas modéliser l'inventaire
comme transaction).

---

## Après S11 — Documentation

Aucune nouvelle table. Les livrables S11 sont des fichiers Markdown :

- `docs/model-card.md` — résumé exécutif de votre entrepôt
- `docs/bus-matrix.md` — matrice processus × dimensions
- `docs/data-dictionary.md` — votre version, pas celle-ci (auto-générée)
- `docs/decision-log.md` — journal des choix de modélisation

---

## Après S13 — Au-delà du modèle

Aucune nouvelle table. Conceptuel (ETL vs ELT, cloud, ROI).

---

## En cas de divergence

Si votre nombre de lignes tombe hors fourchette :

1. Vérifiez votre `team_seed` dans `meta/dataset_identity.json`.
2. Relancez `make generate` pour régénérer depuis zéro.
3. Si l'écart persiste, ouvrez une issue ou demandez au forum.

Les fourchettes tolèrent la variance normale entre équipes — la
*structure* (colonnes, clés, grain) doit par contre être identique.
