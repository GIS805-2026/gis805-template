# GIS805 — Séance 12 / 14 — Comité du board : présentation et défense du modèle NexaMart

> Guide de studio (version Markdown). PDF équivalent : `docs/lab-guides/GIS805-12_lab.pdf`.

## En bref

- **Date :** 15 juin 2026
- **Horaire :** 19 h 00 – 22 h 00
- **Lieu :** Longueuil
- **Temps estimé :** 135 min (~2.2 h)

## Objectif

Présenter et défendre le modèle dimensionnel devant un comité simulé. Démontrer la capacité à justifier les choix de conception sous pression.

## Question du CEO

> « Le modèle est-il prêt à faire face au comité de direction ? »

## Contexte du soir

**NexaMart S12 : Le modèle est-il prêt à faire face au comité de direction ?**

Chaque étudiant soumet un written defense pack. 8-10 étudiants (sélection aléatoire) présentent live au board committee. L''audience joue les rôles de CFO, COO, CMO, CTO avec des questions prédéfinies. La première slide doit montrer le processus métier, le grain, et le diagramme étoile/bus.

## Résultats d'apprentissage

- Présenter un modèle dimensionnel de façon claire et structurée en 8 minutes.
- Défendre les choix de grain, SCD, bridges et types de faits sous questionnement.
- Évaluer les présentations des collègues via la grille de revue.
- Produire le metric definitions pack final.

## Points clés

- La présentation doit répondre à : quelle décision, quel grain, quelle preuve.
- La défense sous pression est une compétence professionnelle, pas un examen.
- Le metric definitions pack est le document final du cours.

## Idées reçues à déjouer

  **Réalité :** Le board veut savoir quelle décision le modèle rend possible, pas comment il est implémenté.
  **Réalité :** Les questions du CFO/COO/CMO/CTO correspondent exactement aux préoccupations réelles d'un comité de direction.

## Déroulé

### Partie 1 — Preparation + rules  *(15 min)*

Rappel format : 8 min présentation + 4 min questions. Rôles du comité.

### Partie 2 — Board presentations  *(90 min)*

8-10 étudiants (sélection aléatoire) × 12 min (8+4). Comité pose des questions ciblées.

### Partie 3 — Deliberation + metric pack  *(30 min)*

Feedback croisé, badges, finalisation metric definitions pack.

## Lab

**Objectif du lab :** Present and defend the dimensional model.

**Livrable :** Written defense pack (all) + live presentation (8-10 random) + metric definitions + Q&A log.

**Fichiers à produire (`repo_artifacts`) :**

- `answers/S12_executive_brief.md`
- `docs/metric-definitions.md`
- `docs/board-q-and-a-log.md`
- `docs/final-model-readme.md`
- `docs/board-briefs/s12-defense.md`

## Remise

- **Échéance :** Before next session starts
- **Artefacts requis :**
  - `answers/S12_executive_brief.md`
  - `db/nexamart.duckdb`
  - `ai-usage.md`
- **Rubrique de notation :**
  - **model_quality** (30 %) — Le modèle présenté est cohérent avec les livrables des sessions précédentes.
  - **validation_quality** (15 %) — Les requêtes citées pendant la défense s'exécutent si demandées par le comité.
  - **executive_justification** (40 %) — La présentation répond à la question CEO en 8 min ± 30 s. Défense sous questionnement réussie. Written defense pack soumis par tous les étudiants.
  - **process_trace** (10 %) — Pack de métriques commité avec définitions des KPIs défendus. AI usage note à jour.
  - **reproducibility** (5 %)

## Lectures

- [Storytelling with Data -- Effective Visual Communication](https://www.storytellingwithdata.com/chart-guide) — Guide pour choisir le bon type de visualisation selon le message a communiquer
- [Kimball Group -- Dimensional Modeling Process](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/four-4-step-702/) — Communiquer et defendre un modele dimensionnel aupres des parties prenantes

---

*Généré automatiquement à partir de `content/sessions/GIS805-12.yaml`. Pour corriger une coquille, modifiez le YAML source et poussez sur `master` — la CI régénère PDF + Markdown.*
