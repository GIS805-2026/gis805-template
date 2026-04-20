# GIS805 — Séance 13 / 14 — Au-delà du modèle : survol des sujets GIS806 pour préparer la suite

> Guide de studio (version Markdown). PDF équivalent : `docs/lab-guides/GIS805-13_lab.pdf`.

## En bref

- **Date :** 18 juin 2026
- **Horaire :** 19 h 00 – 22 h 00
- **Lieu :** Longueuil
- **Temps estimé :** 105 min (~1.8 h)

## Objectif

Explorer les sujets qui viennent après un bon modèle dimensionnel : ETL/ELT, OLAP, cloud, IA. Préparer un roadmap build-vs-buy pour NexaMart.

## Question du CEO

> « NexaMart devrait-il rester local-first, migrer certains workloads au cloud, ou planifier un build GIS806 complet ? »

## Contexte du soir

**NexaMart S13 : NexaMart devrait-il rester local-first, migrer certains work**

Le CEO demande un avis : maintenant que le modèle est solide, quelle est la prochaine étape ? Rester en DuckDB local, passer à BigQuery Sandbox, envisager Snowflake ? Ce n'est pas un cours de plateforme — c'est un exercice stratégique.

## Résultats d'apprentissage

- Positionner ETL/ELT comme la prochaine étape naturelle après la modélisation.
- Distinguer les services OLAP, cloud DW et lakehouse à un niveau conceptuel.
- Rédiger un roadmap 5 points local-first → cloud pour NexaMart.
- Identifier ce qui appartient à GIS806 vs ce qui a été couvert en GIS805.

## Points clés

- GIS805 = structurer la vérité décisionnelle. GIS806 = opérer l'infrastructure.
- Un modèle solide est le prérequis de tout le reste.
- Le roadmap est un exercice stratégique, pas une implémentation.

## Idées reçues à déjouer

  **Réalité :** Sans modèle dimensionnel solide, migrer vers le cloud revient à déménager le désordre dans un endroit plus cher.
  **Réalité :** GIS805 = structurer la vérité décisionnelle. GIS806 = créer, peupler, optimiser et opérer l'infrastructure autour.

## Déroulé

### Partie 1 — Survol ETL/ELT + OLAP  *(30 min)*

15 min ETL/ELT, 15 min OLAP concepts — survey level only

### Partie 2 — Survol cloud + IA  *(25 min)*

15 min cloud landscape, 10 min IA/LLM — survey level only

### Partie 3 — Build-vs-buy roadmap  *(50 min)*

Étudiants rédigent un roadmap 5 points + memo build-vs-buy

## Lab

**Objectif du lab :** Write a 5-point roadmap for NexaMart's next steps.

**Livrable :** Build-vs-buy memo + GIS806 roadmap.

**Fichiers à produire (`repo_artifacts`) :**

- `answers/S13_executive_brief.md`
- `docs/build-vs-buy-memo.md`
- `docs/gis806-roadmap.md`
- `docs/board-briefs/s13-beyond.md`

## Remise

- **Échéance :** Before next session starts
- **Artefacts requis :**
  - `answers/S13_executive_brief.md`
  - `db/nexamart.duckdb`
  - `ai-usage.md`
- **Rubrique de notation :**
  - **model_quality** (40 %) — Roadmap build-vs-buy ancre ETL/ELT comme extension du modèle NexaMart, pas comme son remplacement.
  - **validation_quality** (25 %) — Au moins un pattern dbt ou OLAP est applicable directement au modèle de l'étudiant.
  - **executive_justification** (20 %) — Mémo recommande une option avec coût estimé, critères de décision et prochaine action pour le VP.
  - **process_trace** (10 %) — Handoff doc confirme que modèle final est GIS806-ready : grain documenté, checks passent, README à jour.
  - **reproducibility** (5 %)

## Lectures

- [dbt Labs -- What is ELT?](https://docs.getdbt.com/terms/elt) — Difference entre ETL et ELT dans les architectures modernes
- [Databricks -- Lakehouse Architecture](https://www.databricks.com/glossary/data-lakehouse) — Survol de l'architecture lakehouse comme evolution du data warehouse
- [Snowflake -- Modern Data Stack](https://www.snowflake.com/guides/modern-data-stack/) — Vue d'ensemble de la pile analytique cloud moderne

---

*Généré automatiquement à partir de `content/sessions/GIS805-13.yaml`. Pour corriger une coquille, modifiez le YAML source et poussez sur `master` — la CI régénère PDF + Markdown.*
