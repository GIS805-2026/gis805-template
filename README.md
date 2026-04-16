# GIS805 -- Modelisation dimensionnelle chez NexaMart

## Bienvenue

Ce depot est votre espace de travail pour GIS805. Vous y construirez un modele dimensionnel complet pour NexaMart, une chaine de commerce de detail fictive.

**Premiere visite?** Commencez par [docs/S00-SETUP.md](docs/S00-SETUP.md) -- il vous guide etape par etape, de la creation de compte GitHub jusqu'a votre premiere requete SQL.

## Le boardroom model

Dans ce cours, vous n'etes pas un etudiant qui fait des exercices -- vous etes le **Head of Data** d'un departement NexaMart.

| Role | Responsabilite |
|------|----------------|
| **Instructeur** | CEO de NexaMart -- pose les questions strategiques |
| **Vous** | Head of Data -- construisez les reponses analytiques |
| **Votre repo** | Votre departement -- contient vos modeles et decisions |
| **Votre assistant IA** | Votre co-equipier -- posez-lui des questions en francais |

Chaque semaine, le CEO pose une question au board. Votre livrable : un **executive brief** qui repond a cette question avec des donnees.

### Workflow hebdomadaire

1. **Lire** la question du CEO dans `answers/SXX_executive_brief.md`
2. **Discuter** avec votre assistant IA pour comprendre le probleme
3. **Construire** le modele qui permet de repondre
4. **Valider** vos donnees avec `make check`
5. **Rediger** votre executive brief
6. **Commiter** avant la session suivante

## Regle fondamentale

Vous pouvez utiliser tous les outils que vous voulez pour resoudre les problemes (IA inclus).

Cependant, votre travail final doit etre :

- **Reproductible** -- je peux reconstruire vos resultats
- **Explicable** -- vous pouvez justifier vos choix
- **Inspectable** -- je peux lire votre code et vos donnees
- **Defendable** -- vous savez pourquoi vous avez fait ce que vous avez fait
- **Livrable dans DuckDB** -- c'est notre moteur analytique standard

## Demarrage rapide

Tout est detaille dans [docs/S00-SETUP.md](docs/S00-SETUP.md). En resume :

```bash
# 1. Ouvrir un Codespace (ou cloner localement)
# 2. Generer vos donnees uniques (auto depuis votre username GitHub)
make generate

# 3. Charger dans DuckDB
make load

# 4. Verifier
make check
```

Tapez `make help` pour voir tous les raccourcis disponibles.

## Structure du depot

```
.devcontainer/      # Config Codespace (Python, DuckDB, extensions)
answers/            # Executive briefs hebdomadaires (S01-S14)
data/               # Donnees brutes et transformees
  raw/              # Fichiers CSV generes par votre token
  staged/           # Donnees nettoyees
  exports/          # Exports pour analyse
  metadata/         # Identite du jeu de donnees
db/                 # Base DuckDB
docs/               # Documentation de design
  S00-SETUP.md      # Guide de demarrage (commencez ici)
meta/               # Identite et manifest de soumission
src/                # Scripts Python (generateur, pipeline)
sql/                # Scripts SQL organises
  templates/        # Patterns de reference (dim, fait, SCD, bridge)
  staging/          # Chargement et nettoyage
  dims/             # Creation des dimensions
  sandbox/          # Exploration libre
validation/         # Controles et resultats
  checks.sql        # Verifications consolidees
  checks/           # Verifications individuelles
Makefile            # Raccourcis : make setup/generate/load/check/explore
ai-usage.md         # Trace d'usage IA (obligatoire)
```

## Livrables requis (chaque semaine)

| Element | Emplacement |
|---------|-------------|
| Executive brief | `answers/SXX_executive_brief.md` |
| Base DuckDB | `db/nexamart.duckdb` |
| Resultats de validation | `validation/results/` |
| Trace d'usage IA | `ai-usage.md` |

## Evaluation (5 couches)

| Couche | Ce qui est evalue |
|--------|-------------------|
| **A. Qualite du modele** | Le warehouse repond-il a la question du CEO? Grain explicite? |
| **B. Qualite de validation** | Les nombres sont-ils fiables? Totaux reconcilies? |
| **C. Justification executive** | Pouvez-vous expliquer au CEO? Trade-offs explicites? |
| **D. Trace de processus** | Preuve d'iteration? Problem-solving visible? |
| **E. Reproductibilite** | Le repo fonctionne? Une autre equipe peut continuer? |

## Sessions et milestones

| Session | Theme | Livrable |
|---------|-------|----------|
| S01 | Kickoff NexaMart | Board brief initial |
| S02 | Schema en etoile | Premier modele dim/fait |
| S03 | SCD | Dimensions historisees |
| S04 | Patterns avances | Bridges et flags |
| S05 | **Intra 1** | Examen |
| S06 | Multi-star | Drill-across |
| S07 | Dimensions speciales | Hierarchies, role-playing |
| S08 | M:M | Ponts ponderes |
| S09 | Types de faits | Transaction/snapshot |
| S10 | **Intra 2** | Examen |
| S11 | Documentation | Revue de design |
| S12 | Board committee | Presentation finale |
| S13 | Au-dela | Survol GIS806 |
| S14 | **Final** | Examen |

## Ressources

- [DuckDB Documentation](https://duckdb.org/docs/)
- [Kimball Dimensional Modeling](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/)
- [dbt Analytics Engineering Guide](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview)

## Questions?

Demandez d'abord a votre assistant IA. Sinon, contactez votre instructeur ou utilisez le forum du cours.
