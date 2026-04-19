# GIS805 — Séance 03 / 14 — Dimensions à changement lent : garder la vérité historique chez NexaMart

> Guide de studio (version Markdown). PDF équivalent : `docs/lab-guides/GIS805-03_lab.pdf`.

## En bref

- **Date :** 11 mai 2026
- **Horaire :** 19 h 00 – 22 h 00
- **Lieu :** Longueuil
- **Temps estimé :** 105 min (~1.8 h)

## Objectif

Maîtriser les types SCD 1, 2 et 3 en simulant des changements dans les dimensions NexaMart. Produire la politique SCD du modèle et démontrer l'impact sur les rapports exécutifs.

## Question du CEO

> « Quels changements dans nos dimensions doivent garder la vérité historique, et lesquels peuvent être écrasés ? »

## Contexte du soir

**NexaMart S03 : Quels changements dans nos dimensions doivent garder la véri**

Des clients changent de segment, des magasins changent de région, des noms sont corrigés. Le CEO veut des rapports fiables par rapport à la réalité du moment de la vente, pas celle d'aujourd'hui.

## Résultats d'apprentissage

- Distinguer et implémenter les types SCD 1, 2 et 3.
- Démontrer comment un mauvais choix SCD produit un rapport exécutif trompeur.
- Rédiger une politique SCD justifiée pour les dimensions du modèle.
- Implémenter des clés subrogées et la logique historique dans DuckDB.

## Points clés

- SCD est un choix de politique, pas un choix technique.
- Montrer le mauvais rapport avant le bon rapport est la meilleure pédagogie SCD.
- La politique SCD est un livrable, pas une discussion informelle.

## Idées reçues à déjouer

  **Réalité :** Un UPDATE écrase l'histoire. Si le CEO demande 'ventes par ancienne région', la réponse est perdue.
  **Réalité :** Type 2 préserve l'histoire mais crée de la complexité. Certains attributs (correction de typo) méritent un Type 1.

## Déroulé

### Partie 1 — SCD theory + wrong report demo  *(25 min)*

Types 1/2/3 expliqués, démo du rapport trompeur

### Partie 2 — Sprint 1 : simulate changes  *(40 min)*

Charger customer_changes.csv, implémenter Type 1 et Type 2 côte à côte

### Partie 3 — Sprint 2 : SCD policy + board brief  *(40 min)*

Rédiger la politique SCD, prouver par SQL que l'historique est preservé

## Lab

**Objectif du lab :** Simulate dimension changes and produce correct vs incorrect reports.

**Livrable :** SCD policy + before/after SQL demo + board brief.

**Fichiers à produire (`repo_artifacts`) :**

- `answers/S03_executive_brief.md`
- `sql/scd/type1_vs_type2_demo.sql`
- `docs/scd-policy.md`
- `docs/board-briefs/s03-scd.md`

## Remise

- **Échéance :** Before next session starts
- **Artefacts requis :**
  - `answers/S03_executive_brief.md`
  - `db/nexamart.duckdb`
  - `ai-usage.md`
- **Rubrique de notation :**
  - **model_quality** (40 %) — SCD Type déclaré pour au moins dim_store(region). Schéma distingue current_value et historical_value.
  - **validation_quality** (25 %) — Deux requêtes : rapport trompeur (Type 1) vs rapport correct (Type 2) côte à côte pour une dimension modifiée.
  - **executive_justification** (20 %) — Brief explique au VP pourquoi le rapport historique était inexact et ce qui a changé.
  - **process_trace** (10 %) — docs/scd-policy.md commité avec type retenu + raisonnement business (pas technique).
  - **reproducibility** (5 %)

## Lectures

- [Kimball Group -- Slowly Changing Dimensions](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/type-1-2-3/) — Les trois types de SCD et quand utiliser chacun
- [dbt Labs -- Snapshots (SCD Type 2)](https://docs.getdbt.com/docs/build/snapshots) — Implementation moderne des SCD Type 2 avec dbt snapshots

---

*Généré automatiquement à partir de `content/sessions/GIS805-03.yaml`. Pour corriger une coquille, modifiez le YAML source et poussez sur `master` — la CI régénère PDF + Markdown.*
