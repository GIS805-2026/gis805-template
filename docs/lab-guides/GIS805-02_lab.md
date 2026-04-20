# GIS805 — Séance 02 / 14 — Schéma en étoile, grain et dimensions conformes : le premier modèle NexaMart

> Guide de studio (version Markdown). PDF équivalent : `docs/lab-guides/GIS805-02_lab.pdf`.

## En bref

- **Date :** 7 mai 2026
- **Horaire :** 19 h 00 – 22 h 00
- **Lieu :** Longueuil
- **Temps estimé :** 105 min (~1.8 h)

## Objectif

Concevoir le premier schéma en étoile, définir le grain comme décision irréversible, et prouver par une requête SQL que le modèle répond à la question du CEO.

## Question du CEO

> « Quel schéma en étoile rend votre question CEO répétable et fiable chaque mois ? »

## Contexte du soir

**NexaMart S02 : Quel schéma en étoile rend votre question CEO répétable ?**

Le CEO veut que chaque étudiant modélise son processus principal comme un schéma en étoile. Le grain doit être assez fin pour répondre aux variantes futures de la question, mais pas si fin que la table de faits devienne ingérable.

## Résultats d'apprentissage

- Concevoir un schéma en étoile avec table de faits et dimensions.
- Formaliser un grain statement comme contrat de conception.
- Identifier les dimensions conformes partagées entre tables de faits.
- Écrire une première requête SQL qui prouve que le modèle répond à la question du S01.

## Points clés

- Le grain est un contrat : une ligne dans la table de faits représente exactement...
- Les dimensions conformes partagées (date, product, store) rendent le drill-across possible.
- Un schéma n'est valide que s'il produit une réponse vérifiable.

## Idées reçues à déjouer

  **Réalité :** Le grain est la décision la plus importante et la plus difficile à changer. Un grain trop grossier ferme des questions pour toujours.
  **Réalité :** Chaque dimension doit répondre à un besoin analytique réel. Trop de dimensions créent de la complexité sans valeur.

## Déroulé

### Partie 1 — Grain : la décision irréversible  *(25 min)*

Théorie du grain, additivity, semi-additivity, exemples NexaMart

### Partie 2 — Sprint 1 : schema v1  *(40 min)*

Étudiants modélisent leur étoile, grain statement, diagramme Mermaid

### Partie 3 — Sprint 2 : première réponse SQL  *(40 min)*

Charger fact_sales dans DuckDB, écrire la requête répondant au CEO

## Lab

**Objectif du lab :** Model the star schema and prove it answers the CEO question.

**Livrable :** Schema v1 + grain statement + first SQL answer.

**Fichiers à produire (`repo_artifacts`) :**

- `answers/S02_executive_brief.md`
- `docs/schema-v1.md`
- `diagrams/schema-v1.mmd`
- `sql/analysis/s02-first-answer.sql`
- `docs/board-briefs/s02-star-schema.md`

## Remise

- **Échéance :** Before next session starts
- **Artefacts requis :**
  - `answers/S02_executive_brief.md`
  - `db/nexamart.duckdb`
  - `ai-usage.md`
- **Rubrique de notation :**
  - **model_quality** (40 %) — Grain de fact_sales déclaré ('une ligne = une ligne de commande'). Schéma Mermaid cohérent avec ≥ 3 dimensions.
  - **validation_quality** (25 %) — Requête retourne les ventes par catégorie, région et trimestre sans erreur.
  - **executive_justification** (20 %) — Brief situe le résultat dans le contexte des ventes NexaMart en déclin.
  - **process_trace** (10 %) — Decision log documente le choix de grain avec justification business.
  - **reproducibility** (5 %)

## Lectures

- [Kimball Group -- Star Schema Fundamentals](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/star-schema-olap-cube/) — Le schema en etoile et la declaration du grain
- [dbt Labs -- How we structure our dbt projects](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview) — Bonnes pratiques de structuration analytique moderne
- [DuckDB -- SQL Introduction](https://duckdb.org/docs/sql/introduction) — Syntaxe SQL dans DuckDB pour creer tables et vues

---

*Généré automatiquement à partir de `content/sessions/GIS805-02.yaml`. Pour corriger une coquille, modifiez le YAML source et poussez sur `master` — la CI régénère PDF + Markdown.*
