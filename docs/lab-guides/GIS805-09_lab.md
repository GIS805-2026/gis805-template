# GIS805 — Séance 09 / 14 — Les quatre types de tables de faits : transaction, snapshot, accumulating et factless

> Guide de studio (version Markdown). PDF équivalent : `docs/lab-guides/GIS805-09_lab.pdf`.

## En bref

- **Date :** 4 juin 2026
- **Horaire :** 19 h 00 – 22 h 00
- **Lieu :** Longueuil
- **Temps estimé :** 105 min (~1.8 h)

## Objectif

Classifier et implémenter les quatre types de tables de faits à travers la carte des processus NexaMart, et comprendre la modélisation des taux.

## Question du CEO

> « Quels processus NexaMart sont transactionnels, quels sont des snapshots, et quels sont de simples présences ? »

## Contexte du soir

**NexaMart S09 : Quels processus NexaMart sont transactionnels, quels sont de**

NexaMart a 4 processus très différents : ventes (transactionnel), inventaire quotidien (snapshot périodique), pipeline de commandes order→payment→pick→ship→deliver (accumulating), et exposition promotionnelle (factless). Chaque type nécessite un modèle différent.

## Résultats d'apprentissage

- Distinguer transaction, periodic snapshot, accumulating snapshot et factless facts.
- Mapper les processus NexaMart aux types de faits appropriés.
- Implémenter un snapshot accumulant pour le pipeline de commandes.
- Créer une table de faits sans mesure (factless) pour l'exposition promotionnelle.

## Points clés

- Transaction = événement ponctuel. Snapshot = état à un moment. Accumulating = cycle de vie.
- Factless = l'existence est le fait. Pas de mesure, mais une réponse réelle.
- La carte des types de faits est un outil de diagnostic pour tout processus.

## Idées reçues à déjouer

  **Réalité :** Les snapshots périodiques (inventaire quotidien) et les accumulating snapshots (pipeline) sont fondamentalement différents des transactions.
  **Réalité :** Une factless fact table enregistre des événements ou des couvertures — l'existence est le fait.

## Déroulé

### Partie 1 — 4 fact types theory + NexaMart process map  *(20 min)*

Transaction, periodic, accumulating, factless — mapped to NexaMart

### Partie 2 — Sprint 1 : transaction + periodic snapshot  *(40 min)*

Charger fact_orders_transaction et fact_daily_inventory, comparer

### Partie 3 — Sprint 2 : accumulating + factless + process map  *(45 min)*

Pipeline accumulant, exposition promotionnelle, decision tree

## Lab

**Objectif du lab :** Map four NexaMart processes to four fact table types.

**Livrable :** Typed fact map + four example queries + decision tree + board brief.

**Fichiers à produire (`repo_artifacts`) :**

- `answers/S09_executive_brief.md`
- `docs/fact-type-decision-tree.md`
- `docs/process-map.md`
- `sql/fact-types/`
- `docs/board-briefs/s09-fact-types.md`

## Remise

- **Échéance :** Before next session starts
- **Artefacts requis :**
  - `answers/S09_executive_brief.md`
  - `db/nexamart.duckdb`
  - `ai-usage.md`
- **Rubrique de notation :**
  - **model_quality** (40 %) — 4 types de tables de faits présents ou documentés. fact_inventory_snapshot utilise snapshot, pas calcul.
  - **validation_quality** (25 %) — Requête stock périodique retourne un résultat par période sans cumul des transactions.
  - **executive_justification** (20 %) — L'arbre de décision des types de faits est commité et applicable à de nouveaux processus NexaMart.
  - **process_trace** (10 %) — docs/fact-types-map.md documente quel type répond à quel type de question business.
  - **reproducibility** (5 %)

## Lectures

- [Kimball Group -- Fact Table Types](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/transaction-fact-table/) — Les 4 types de tables de faits (transaction, snapshot periodique, accumulating, factless)
- [Kimball Group -- Periodic Snapshot Fact Table](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/periodic-snapshot-fact-table/) — Capturer l'etat a un moment donne (inventaire, soldes, KPIs periodiques)

---

*Généré automatiquement à partir de `content/sessions/GIS805-09.yaml`. Pour corriger une coquille, modifiez le YAML source et poussez sur `master` — la CI régénère PDF + Markdown.*
