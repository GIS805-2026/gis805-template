# GIS805 — Séance 11 / 14 — Processus de modélisation, documentation et revue de design

> Guide de studio (version Markdown). PDF équivalent : `docs/lab-guides/GIS805-11_lab.pdf`.

## En bref

- **Date :** 11 juin 2026
- **Horaire :** 19 h 00 – 22 h 00
- **Lieu :** Longueuil
- **Temps estimé :** 105 min (~1.8 h)

## Objectif

Préparer un pack de documentation et de handoff qui permettrait à un nouvel analyste de comprendre et continuer le modèle NexaMart dès lundi matin.

## Question du CEO

> « Si le lead analyste quitte NexaMart vendredi soir, un collègue peut-il continuer lundi matin ? »

## Contexte du soir

**NexaMart S11 : Si le lead analyste quitte NexaMart vendredi soir, une autre**

Le CEO simule un départ : le lead analyste part. Chaque étudiant doit produire un pack de documentation minimal qui permet la continuité. Les étudiants échangent ensuite pour évaluer le pack d'un collègue.

## Résultats d'apprentissage

- Rédiger un model card complet pour le modèle NexaMart.
- Documenter le bus matrix, le dictionnaire de données et le decision log.
- Préparer un pack de handoff minimal mais suffisant.
- Évaluer un modèle concurrent via la grille de revue de design.

## Points clés

- Le handoff pack est un livrable, pas un bonus.
- Model card = grain + faits + dimensions + SCD + nulls + risques + vérifications.
- Le bus matrix est le document le plus important pour la conformité.

## Idées reçues à déjouer

  **Réalité :** Sans documentation, le modèle est utilisable par une seule personne. Le handoff pack est un livrable au même titre que le SQL.
  **Réalité :** Le schéma montre la structure, pas les décisions. Le grain statement, la politique SCD, et les risques connus sont invisibles dans un diagramme.

## Déroulé

### Partie 1 — Documentation as deliverable  *(20 min)*

Model card, bus matrix, data dictionary, decision log

### Partie 2 — Sprint 1 : build handoff pack  *(50 min)*

Étudiants rédigent model card + bus matrix + dictionary

### Partie 3 — Sprint 2 : peer design review  *(35 min)*

Échange de packs entre étudiants, revue avec grille

## Lab

**Objectif du lab :** Create the smallest documentation pack for continuity.

**Livrable :** Model card + decision log + dictionary + bus matrix.

**Fichiers à produire (`repo_artifacts`) :**

- `answers/S11_executive_brief.md`
- `docs/model-card.md`
- `docs/decision-log.md`
- `docs/data-dictionary.md`
- `docs/bus-matrix.md`
- `docs/board-briefs/s11-handoff.md`

## Remise

- **Échéance :** Before next session starts
- **Artefacts requis :**
  - `answers/S11_executive_brief.md`
  - `db/nexamart.duckdb`
  - `ai-usage.md`
- **Rubrique de notation :**
  - **model_quality** (20 %) — Model card couvre grain, faits, dimensions, SCD et bridges appliqués au modèle de l'étudiant.
  - **validation_quality** (20 %) — Les checks SQL s'exécutent depuis le repo cloné d'un tiers sans modification.
  - **executive_justification** (20 %) — La bus matrix et le decision log permettent à un analyste junior de comprendre les décisions clés.
  - **process_trace** (30 %) — Handoff pack commité : model-card.md, bus-matrix.md, data-dictionary.md, decision-log.md, board-briefs/.
  - **reproducibility** (10 %)

## Lectures

- [dbt Labs -- Model Documentation](https://docs.getdbt.com/docs/collaborate/documentation) — Bonnes pratiques de documentation pour les modeles analytiques
- [Kimball Group -- Dimensional Modeling Process](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/four-4-step-702/) — Les 4 etapes du processus de modelisation dimensionnelle

---

*Généré automatiquement à partir de `content/sessions/GIS805-11.yaml`. Pour corriger une coquille, modifiez le YAML source et poussez sur `master` — la CI régénère PDF + Markdown.*
