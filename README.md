# GIS805 — Modélisation dimensionnelle chez NexaMart

## Bienvenue

Ce dépôt est votre espace de travail pour GIS805. Vous y construirez un modèle dimensionnel complet pour NexaMart, une chaîne de commerce de détail fictive.

## 🏢 Le boardroom model

Dans ce cours, vous n'êtes pas un étudiant qui fait des exercices — vous êtes le **Head of Data** d'un département NexaMart.

| Rôle | Responsabilité |
|------|----------------|
| **Instructeur** | CEO de NexaMart — pose les questions stratégiques |
| **Vous** | Head of Data — construisez les réponses analytiques |
| **Votre repo** | Votre département — contient vos modèles et décisions |

Chaque semaine, le CEO pose une question au board. Votre livrable : un **executive brief** qui répond à cette question avec des données.

### Workflow hebdomadaire

1. **Lire** la question du CEO dans `answers/SXX_executive_brief.md`
2. **Construire** le modèle qui permet de répondre
3. **Valider** vos données avec les scripts de `validation/`
4. **Rédiger** votre executive brief
5. **Commiter** avant la session suivante

## Règle fondamentale

Vous pouvez utiliser tous les outils que vous voulez pour résoudre les problèmes.

Cependant, votre travail final doit être :
- **Reproductible** — je peux reconstruire vos résultats
- **Explicable** — vous pouvez justifier vos choix
- **Inspectable** — je peux lire votre code et vos données
- **Défendable** — vous savez pourquoi vous avez fait ce que vous avez fait
- **Livrable dans DuckDB** — c'est notre moteur analytique standard

## Démarrage rapide

### 1. Générer vos données uniques
```bash
python src/generate_data.py --token VOTRE_TOKEN
```
Votre token vous sera fourni individuellement. Il génère un jeu de données unique mais comparable aux autres étudiants.

### 2. Explorer avec DuckDB
```bash
duckdb db/nexamart.duckdb
```

### 3. Construire vos modèles
- Placez vos scripts SQL dans `sql/`
- Documentez vos décisions dans `docs/`
- Validez avec les scripts dans `validation/`

## Structure du dépôt

```
├── answers/        # Executive briefs hebdomadaires (S01-S14)
├── data/           # Données brutes et transformées
│   ├── raw/        # Fichiers CSV générés
│   ├── staged/     # Données nettoyées
│   ├── exports/    # Exports pour analyse
│   └── metadata/   # Identité du jeu de données
├── db/             # Base DuckDB
├── meta/           # Identité et manifest de soumission
├── src/            # Scripts Python
├── sql/            # Scripts SQL organisés
│   ├── staging/    # Chargement et nettoyage
│   ├── dims/       # Création des dimensions
│   ├── facts/      # Création des faits
│   ├── views/      # Vues analytiques
│   ├── checks/     # Validation SQL
│   └── sandbox/    # Exploration libre
├── docs/           # Documentation de design
├── validation/     # Contrôles et résultats
└── submissions/    # Livrables par assignment
```

## Livrables requis (chaque semaine)

| Élément | Emplacement |
|---------|-------------|
| Executive brief | `answers/SXX_executive_brief.md` |
| Base DuckDB | `db/nexamart.duckdb` |
| Résultats de validation | `validation/results/` |
| Trace d'usage IA | `ai-usage.md` |

## Évaluation (5 couches)

| Couche | Ce qui est évalué |
|--------|-------------------|
| **A. Qualité du modèle** | Le warehouse répond-il à la question du CEO ? Grain explicite ? |
| **B. Qualité de validation** | Les nombres sont-ils fiables ? Totaux réconciliés ? |
| **C. Justification exécutive** | Pouvez-vous expliquer au CEO ? Trade-offs explicites ? |
| **D. Trace de processus** | Preuve d'itération ? Problem-solving visible ? |
| **E. Reproductibilité** | Le repo fonctionne ? Une autre équipe peut continuer ? |

## Sessions et milestones

| Session | Thème | Livrable |
|---------|-------|----------|
| S01 | Kickoff NexaMart | Board brief initial |
| S02 | Schéma en étoile | Premier modèle dim/fait |
| S03 | SCD | Dimensions historisées |
| S04 | Patterns avancés | Bridges et flags |
| S05 | **Intra 1** | Examen |
| S06 | Multi-star | Drill-across |
| S07 | Dimensions spéciales | Hiérarchies, role-playing |
| S08 | M:M | Ponts pondérés |
| S09 | Types de faits | Transaction/snapshot |
| S10 | **Intra 2** | Examen |
| S11 | Documentation | Revue de design |
| S12 | Board committee | Présentation finale |
| S13 | Au-delà | Survol GIS806 |
| S14 | **Final** | Examen |

## Ressources

- [DuckDB Documentation](https://duckdb.org/docs/)
- [Kimball Dimensional Modeling](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/)

## Questions?

Contactez votre instructeur ou utilisez le forum de discussion du cours.
