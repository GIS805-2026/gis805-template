# GIS805 — NexaMart Dimensional Warehouse

> **Vous êtes le Head of Data de NexaMart Group.**
> Vous construisez l'entrepôt analytique dimensionnel complet de l'entreprise,
> une table de faits à la fois, sur 14 séances.

## Votre mission

Le CEO de NexaMart pose une question stratégique chaque semaine.
Les systèmes opérationnels (ERP, CRM, POS) ne peuvent pas y répondre.
Vous concevez, construisez et défendez le modèle dimensionnel qui rend
ces réponses **répétables, vérifiables et défendables** devant le board.

## Ce que vous construisez

### 5 tables de faits principales

| # | Table | Séance | Grain | Pattern |
|---|-------|--------|-------|---------|
| 1 | `fact_sales` | S02 | 1 ligne = 1 ligne de commande | Étoile, grain, additivité |
| 2 | `fact_returns` | S06 | 1 ligne = 1 retour | Drill-across, conformité |
| 3 | `fact_budget` | S06 | 1 ligne = catégorie × magasin × mois | Réel vs cible, résolution de grain |
| 4 | `fact_daily_inventory` | S09 | 1 ligne = produit × magasin × date | Snapshot périodique, semi-additivité |
| 5 | `fact_order_pipeline` | S09 | 1 ligne = cycle de vie d'une commande | Snapshot accumulant, dates role-playing |

### Structures complémentaires

| Structure | Séance | Pattern |
|-----------|--------|---------|
| `junk_order_profile` | S04 | Dimension poubelle (drapeaux consolidés) |
| `bridge_customer_segment` | S08 | Pont pondéré M:N, réconciliation |
| `fact_promo_exposure` | S09 | Fait sans mesure (factless fact) |

## Prérequis & installation

### 1. Python 3.10+

Vérifiez que Python est installé :

```bash
python --version   # doit afficher 3.10 ou plus
```

> **Windows :** Si Python n'est pas reconnu, installez-le depuis
> [python.org](https://www.python.org/downloads/) en cochant
> **« Add Python to PATH »** lors de l'installation.
>
> **Mac :** `brew install python` ou téléchargez depuis python.org.

### 2. Installer les dépendances

```bash
pip install -r requirements.txt
```

Cela installe `duckdb`, le moteur analytique utilisé pour l’entrepôt.

### 3. Vérifier git

```bash
git config user.name
```

Doit afficher votre nom. Si vide :

```bash
git config --global user.name "Prénom Nom"
```

> Votre `user.name` sert de graine déterministe — chaque étudiant
> génère des données **uniques** mais **reproductibles**.

### 4. C'est tout — vous êtes prêt !

> **GitHub Codespaces :** Si disponible, cliquez simplement **« Open in Codespace »**
> depuis votre repo GitHub — Python et les dépendances sont pré-installés,
> aucune configuration locale nécessaire.

## Démarrage rapide

```bash
# === Mac / Linux / WSL ===
make generate        # Générer vos données uniques
make load            # Charger dans DuckDB
make check           # Valider l'intégrité

# === Windows (PowerShell) ===
.\run.ps1 generate
.\run.ps1 load
.\run.ps1 check
```

> **Setup** : Consultez [`docs/S00-SETUP.md`](docs/S00-SETUP.md) pour le guide complet
> de configuration (Codespace, VS Code local, assistant IA).
>
> **FAQ** : Consultez [`docs/faq.md`](docs/faq.md) pour les questions fréquentes
> (vues vs DW, travail individuel, choix de DuckDB, etc.)
>
> **Exemple** : Voir [`docs/s02-sample-brief.md`](docs/s02-sample-brief.md)
> pour un executive brief annoté montrant le standard attendu.

## Structure du repo

```
├── README.md              <- Ce fichier
├── ai-usage.md            <- Trace obligatoire de vos interactions IA
├── Makefile               <- Orchestration Mac/Linux (generate, load, check)
├── run.ps1                <- Orchestration Windows (generate, load, check)
├── requirements.txt
├── .gitignore
├── .devcontainer/         <- Config Codespace (Python 3.12, DuckDB, extensions)
├── .github/
│   ├── workflows/         <- CI GitHub Classroom (autograding)
│   └── grading/           <- Script de validation automatique
├── meta/
│   ├── dataset_identity.json  <- Empreinte anti-copie
│   └── submission_manifest.yaml <- Suivi des sessions
├── answers/               <- Un executive brief par seance (S01-S14)
├── submissions/           <- Templates d'assignments (a1, a2, final)
├── data/
│   ├── synthetic/         <- CSVs generes par make generate (git-ignore)
│   ├── staged/
│   └── exports/
├── scripts/
│   └── datagen/           <- Generateurs de donnees (ne pas modifier)
│       ├── gen_all.py       <- Point d'entree (appele par make generate)
│       ├── _helpers.py      <- Catalogue NexaMart + utilitaires
│       └── gen_s*.py        <- Un generateur par seance (S02-S09)
├── db/
│   └── nexamart.duckdb    <- Genere par make load (git-ignore)
├── src/
│   ├── run_pipeline.py    <- Chargement CSVs -> DuckDB + SQL pipeline
│   ├── run_checks.py      <- Validation (appele par make check)
│   └── helpers/
├── sql/
│   ├── staging/           <- Vues de nettoyage (stg_*)
│   ├── dims/              <- DDL des dimensions (stubs pre-crees)
│   ├── facts/             <- DDL des tables de faits (stubs pre-crees)
│   ├── views/             <- Vues drill-across, reel vs cible
│   ├── templates/         <- 5 patterns SQL annotes (dim, fact, SCD2, bridge, check)
│   ├── checks/            <- SQL de validation
│   └── sandbox/           <- Vos explorations libres
├── docs/
│   ├── S00-SETUP.md       <- Guide de configuration (3 chemins)
│   ├── s02-sample-brief.md <- Exemple annote de brief
│   ├── faq.md             <- Questions frequentes
│   ├── peer-reviews/      <- 3 revues de pairs (jalons)
│   ├── model-card.md      <- Carte du modele (S11)
│   ├── bus-matrix.md      <- Matrice bus (S06+)
│   ├── data-dictionary.md <- Dictionnaire de donnees (S11)
│   ├── decision-log.md    <- Journal des decisions (S11)
│   ├── metric-definitions.md <- Definitions KPI (S12)
│   ├── problem-framing.md
│   └── schema-notes.md
├── validation/
│   ├── checks.sql         <- Monolithique (legacy)
│   ├── checks/            <- 7 checks modulaires (00-06)
│   ├── rules.yaml
│   └── results/
└── tools/
    └── instructor/        <- Outils instructeur (roster, batch pull/validate)
```

## Politique IA

Tout usage d'IA (ChatGPT, Copilot, Claude, etc.) **doit** être tracé dans `ai-usage.md`.

✅ **Permis :** expliquer des concepts, générer du DDL, rédiger des ébauches de SQL ou de documentation
❌ **Interdit :** soumettre du contenu IA sans validation humaine, masquer une incompréhension, copier le SQL d'un autre étudiant

Chaque entrée dans `ai-usage.md` inclut : date, prompt exact, modèle utilisé, comment vous avez validé/modifié le résultat.

## Livrables par séance

| Seance | Livrable principal | Fichier |
|--------|--------------------|---------|
| S01 | Brief executif -- question + obstacles | `answers/S01_executive_brief.md` |
| S02 | Grain statement + etoile + SQL preuve | `answers/S02_executive_brief.md` + `sql/facts/fact_sales.sql` |
| S03 | Politique SCD + comparaison avant/apres | `answers/S03_executive_brief.md` |
| S04 | Dimension poubelle + analyse panier | `answers/S04_executive_brief.md` + `sql/facts/junk_order_profile.sql` |
| S06 | Bus matrix + drill-across + reel vs cible | `answers/S06_executive_brief.md` + `sql/views/` |
| S07 | Hierarchies + politique NULLs + delais | `answers/S07_executive_brief.md` |
| S08 | Pont pondere + reconciliation | `answers/S08_executive_brief.md` + `sql/facts/bridge_customer_segment.sql` |
| S09 | Arbre de decision types de faits + process map | `answers/S09_executive_brief.md` + `sql/facts/` |
| S11 | Model card + bus matrix + dictionnaire + journal | `docs/` |
| S12 | Pack defense ecrit (+ presentation si selectionne) | `docs/metric-definitions.md` |
| S13 | Memo build-vs-buy | `answers/S13_executive_brief.md` |

## Revues de pairs

Trois revues structurées aux jalons clés :

1. **Revue 1** (après S04) — Grain, SCD, dimensions poubelle
2. **Revue 2** (après S09) — Drill-across, ponts, 4 types de faits
3. **Revue 3** (S11) — Pack documentation complet

Appariement aléatoire à chaque jalon. Vos commentaires de revue sont notés.

## Références

- Kimball Group — Dimensional Modeling Techniques
- dbt Labs — Analytics Engineering Guide
- DuckDB Documentation
- Kimball & Ross — *The Data Warehouse Toolkit* (3rd ed.)
