# GIS805 -- Bienvenue dans votre entrepot de donnees

Vous venez d'accepter votre premier assignment. Ce depot est **votre espace de travail** pour tout le trimestre.

> **Le scenario :** Vous etes le Head of Data de NexaMart, une chaine de
> commerce de detail. Chaque semaine, le CEO pose une question strategique
> -- et les systemes operationnels ne peuvent pas y repondre. Votre job :
> construire l'entrepot de donnees qui rend ces reponses possibles.

Pas besoin d'etre programmeur. Vous travaillez en **langage naturel d'abord** :
un assistant IA est votre co-equipier, vous lui posez des questions en francais,
et vous developpez votre jugement sur les reponses.

---

## Demarrage -- choisissez votre chemin

### Chemin A : Codespace (recommande -- zero installation)

Tout se passe dans votre navigateur. Rien a installer.

1. Sur la page de votre depot, cliquez **Code** (bouton vert) puis **Codespaces** puis **Create codespace on main**
2. Attendez environ 2 minutes -- un editeur VS Code s'ouvre avec tout deja configure
3. C'est tout. Passez a la section suivante

> Votre GitHub Student Developer Pack vous donne 60 heures/mois gratuites.
> Pensez a arreter votre Codespace quand vous ne travaillez pas
> (menu `...` en haut a gauche puis **Stop Codespace**).

### Chemin B : VS Code sur votre ordinateur

Si vous preferez travailler en local, ou si vos heures Codespace sont epuisees.

1. Installez [VS Code](https://code.visualstudio.com/), [Python 3.10+](https://www.python.org/downloads/) et [Git](https://git-scm.com/downloads)
2. Dans VS Code, installez les extensions **GitHub Copilot** et **GitHub Copilot Chat** (gratuit via Student Developer Pack)
3. Clonez votre depot : palette de commandes (`Ctrl+Shift+P`) puis **Git: Clone**
4. Ouvrez un terminal dans VS Code et tapez :
   ```bash
   pip install -r requirements.txt
   ```

> Le guide complet avec toutes les etapes est dans [`docs/S00-SETUP.md`](docs/S00-SETUP.md).

### Votre premier reflexe

Quel que soit le chemin choisi, ouvrez **Copilot Chat** (icone de bulle dans
la barre laterale) et posez votre premiere question :

> **Qu'est-ce qui se trouve dans mon depot? Explique-moi la structure du projet.**

Vous venez de faire votre premiere interaction de travail assistee par IA.
C'est exactement comme ca qu'on travaille dans ce cours.

---

## Vos premieres commandes

Dans le terminal, lancez ces trois commandes dans l'ordre :

```bash
# Mac / Linux / Codespace
make generate        # Genere vos donnees uniques (liees a votre username)
make load            # Charge les donnees dans la base DuckDB
make check           # Verifie que tout est correct
```

```powershell
# Windows PowerShell
.\run.ps1 generate
.\run.ps1 load
.\run.ps1 check
```

Si `check` affiche tout en vert, vous etes pret pour la seance 1.

> **Pas sur de ce que font ces commandes?** Demandez a votre assistant IA :
> *"Qu'est-ce que fait `make generate`?"*

---

## Ce que vous construisez

Au fil des 14 seances, vous construisez l'entrepot analytique complet de NexaMart :

1. **`fact_sales`** (S02) -- Les ventes, ligne par ligne
2. **`fact_returns`** (S06) -- Les retours et remboursements
3. **`fact_budget`** (S06) -- Le budget par categorie, magasin et mois
4. **`fact_daily_inventory`** (S09) -- L'inventaire quotidien
5. **`fact_order_pipeline`** (S09) -- Le cycle de vie des commandes

Plus trois structures complementaires : une dimension consolidee (`junk_order_profile`),
un pont clients-segments (`bridge_customer_segment`), et une table de faits sans mesure
(`fact_promo_exposure`). Vous les decouvrirez en classe.

Chaque table est accompagnee de dimensions (clients, produits, magasins, dates, canaux)
et d'un brief executif que vous redigez pour le CEO.

---

## Livrables par seance

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

> Un exemple annote de brief executif est dans [`docs/s02-sample-brief.md`](docs/s02-sample-brief.md).

Trois **revues de pairs** aux jalons cles (apres S04, apres S09, a S11).
Appariement aleatoire a chaque jalon -- vos commentaires de revue sont notes.

---

## Politique IA

Tout usage d'IA (ChatGPT, Copilot, Claude, etc.) **doit** etre trace dans `ai-usage.md`.

- **Permis :** expliquer des concepts, generer du DDL, rediger des ebauches de SQL ou de documentation
- **Interdit :** soumettre du contenu IA sans validation humaine, masquer une incomprehension, copier le SQL d'un autre etudiant

Chaque entree dans `ai-usage.md` inclut : date, prompt exact, modele utilise, comment vous avez valide/modifie le resultat.

---

## Besoin d'aide?

| Ressource | Description |
|-----------|-------------|
| [`docs/S00-SETUP.md`](docs/S00-SETUP.md) | Guide complet de configuration (3 chemins, depannage) |
| [`docs/faq.md`](docs/faq.md) | Questions frequentes (DuckDB, travail individuel, etc.) |
| [`docs/s02-sample-brief.md`](docs/s02-sample-brief.md) | Exemple annote de brief executif |
| Votre assistant IA | **Premier reflexe** -- posez-lui la question en francais |

---

## Structure du depot

```
answers/           Vos briefs executifs (un par seance)
submissions/       Templates des 3 remises (a1, a2, final)
sql/               Votre code SQL (staging, dims, facts, views)
  templates/       5 patterns SQL annotes pour vous guider
  sandbox/         Vos explorations libres
data/              Donnees generees (unique a vous)
scripts/datagen/   Generateurs de donnees (ne pas modifier)
docs/              Guides, FAQ, templates de documentation
meta/              Empreinte de votre jeu de donnees
validation/        Checks automatiques (utilises par make check)
.devcontainer/     Config Codespace (Python, DuckDB, extensions)
.github/           CI et autograding GitHub Classroom
```

> Envie d'en savoir plus? Demandez a votre assistant :
> *"Explique-moi a quoi sert chaque dossier dans ce projet."*

---

## References

- Kimball & Ross -- *The Data Warehouse Toolkit* (3rd ed.)
- Kimball Group -- Dimensional Modeling Techniques
- dbt Labs -- Analytics Engineering Guide
- DuckDB Documentation
