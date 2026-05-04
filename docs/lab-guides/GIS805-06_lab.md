# GIS805 — Séance 06 / 14 — Soirée d'intégration : multi-star, drill-across et réel-vs-cible

> Guide de studio (version Markdown). PDF équivalent : `docs/lab-guides/GIS805-06_lab.pdf`.

## En bref

- **Date :** 25 mai 2026
- **Horaire :** 19 h 00 – 22 h 00
- **Lieu :** Longueuil
- **Temps estimé :** 105 min (~1.8 h)

## Objectif

Intégrer les étoiles indépendantes de NexaMart via les dimensions conformes. Construire 4 tables de faits, écrire des requêtes drill-across, et comparer le réel aux cibles budgétaires.

## Question du CEO

> « Le board peut-il voir ventes, retours, inventaire et budget dans une seule vue sans mentir ? »

## Contexte du soir

**NexaMart S06 : Le board peut-il voir ventes, retours, inventaire et budget **

C'est la soirée d'intégration. Jusqu'à présent, chaque étoile existait indépendamment. Le CEO veut une vue consolidée : ventes réelles vs budget, taux de retour par catégorie, et niveaux d'inventaire. Tout doit passer par des dimensions conformes.

## Résultats d'apprentissage

- Concevoir plusieurs tables de faits partageant des dimensions conformes.
- Écrire une requête drill-across correcte entre fact_sales et fact_returns.
- Construire une vue réel-vs-budget sans joindre des faits entre elles.
- Publier un bus matrix documentant la conformité entre vos tables de faits.

## Points clés

- Cette soirée intègre vos étoiles indépendantes en un entrepôt cohérent.
- Chaque jointure doit passer par des dimensions conformes — jamais fact-to-fact.
- Le bus matrix est le document le plus important de l'intégration.

## Idées reçues à déjouer

  **Réalité :** Joindre fact_sales à fact_returns crée un produit cartésien. Le drill-across passe par les dimensions conformes.
  **Réalité :** fact_budget est mensuel par catégorie×magasin. fact_sales est transactionnel. Le drill-across exige une agrégation au grain commun.

## Déroulé

### Partie 1 — Multi-star theory + bus matrix  *(20 min)*

Dimensions conformes, drill-across, grains multiples

### Partie 2 — Sprint 1 : integration night  *(45 min)*

Charger 4 fact tables, vérifier conformité, écrire drill-across

### Partie 3 — Sprint 2 : actual-vs-budget + board report  *(40 min)*

Vue réel-vs-cible, rapport consolidé pour le board

## Lab

**Objectif du lab :** Integrate independent star schemas through conformed dimensions.

**Livrable :** Bus matrix + drill-across queries + actual-vs-budget view + board report.

**Fichiers à produire (`repo_artifacts`) :**

- `answers/S06_executive_brief.md`
- `docs/bus-matrix.md`
- `sql/integration/s06-drill-across.sql`
- `sql/integration/s06-actual-vs-budget.sql`
- `sql/checks/s06-reconciliation.sql`
- `docs/board-briefs/s06-enterprise-view.md`

## Remise

- **Échéance :** Before next session starts
- **Artefacts requis :**
  - `answers/S06_executive_brief.md`
  - `db/nexamart.duckdb`
  - `ai-usage.md`
- **Rubrique de notation :**
  - **model_quality** (40 %) — Bus matrix complète. Drill-across entre deux fact tables via une dimension conforme.
  - **validation_quality** (25 %) — Requête drill-across retourne un résultat cohérent entre les deux tables (même dimension de jointure).
  - **executive_justification** (20 %) — Brief répond à une question qui nécessite les deux tables. Énonce explicitement la dimension conforme utilisée.
  - **process_trace** (10 %) — Bus matrix commitée dans docs/bus-matrix.md. Décision de grain partagé documentée.
  - **reproducibility** (5 %)

## Lectures

- [Kimball Group -- Conformed Dimensions](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/conformed-dimension/) — Dimensions partagees entre tables de faits pour le drill-across
- [Kimball Group -- Enterprise Data Warehouse Bus Architecture](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/kimball-data-warehouse-bus-architecture/) — La bus matrix comme outil d'integration entre tables de faits
- [DuckDB -- Multiple Result Sets](https://duckdb.org/docs/sql/query_syntax/select) — Syntaxe SQL pour les requetes multi-tables et les CTEs

---

*Généré automatiquement à partir de `content/sessions/GIS805-06.yaml`. Pour corriger une coquille, modifiez le YAML source et poussez sur `master` — la CI régénère PDF + Markdown.*
