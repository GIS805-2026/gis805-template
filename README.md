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

Dans le terminal, lancez ces trois commandes dans l'ordre.
**Choisissez le bloc correspondant a votre plateforme -- les deux sont strictement equivalents** :

```bash
# --- Mac / Linux / Codespace ---
make generate        # Genere vos donnees uniques (liees a votre username)
make load            # Charge les donnees dans la base DuckDB
make check           # Verifie que tout est correct
```

```powershell
# --- Windows PowerShell ---
.\run.ps1 generate   # Genere vos donnees uniques (liees a votre username)
.\run.ps1 load       # Charge les donnees dans la base DuckDB
.\run.ps1 check      # Verifie que tout est correct
```

> **Windows + `make` ?** Git Bash / WSL comprennent `make`, mais sous PowerShell natif utilisez `.\run.ps1`. Les deux appellent exactement les memes scripts Python.

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

Vous creez vous-meme chaque brief dans `answers/SXX_executive_brief.md`.
Pas de gabarit pre-rempli -- voir [`answers/README.md`](answers/README.md) pour
les sections attendues et [`docs/s02-sample-brief.md`](docs/s02-sample-brief.md)
pour un exemple annote.

| Seance | Livrable principal |
|--------|--------------------|
| S01 | Brief executif -- question + obstacles + diagnostic |
| S02 | Grain statement + etoile + SQL preuve (`sql/facts/fact_sales.sql`) |
| S03 | Politique SCD + comparaison avant/apres |
| S04 | Dimension poubelle + degenerate + analyse panier |
| S06 | Bus matrix + drill-across + reel-vs-cible (`sql/views/*.sql`) |
| S07 | Hierarchies + politique NULLs + role-playing dates |
| S08 | Pont pondere + reconciliation |
| S09 | Arbre de decision types de faits + process map |
| S11 | Model card + bus matrix + dictionnaire + journal de decisions (`docs/`) |
| S12 | Pack defense ecrit (+ presentation si tire au sort) |
| S13 | Memo build-vs-buy + feuille de route GIS806 |

Trois **revues de pairs** aux jalons cles (apres S04, apres S09, a S11).
Appariement aleatoire a chaque jalon -- voir `docs/peer-reviews/`.

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

```text
answers/           Vos briefs executifs (un par seance) -- VOUS les creez
submissions/       Dossiers de remise (a1, a2, final) -- vides au depart
sql/
  staging/         Vos vues de nettoyage intermediaires
  dims/            Vos dimensions (dim_*.sql)
  facts/           Vos tables de faits (fact_*.sql)
  views/           Vos vues analytiques / drill-across
  checks/          Vos checks SQL personnels
  templates/       5 patterns SQL annotes -- a etudier, pas a copier aveuglement
  sandbox/         Vos explorations libres
scripts/datagen/   Generateurs de donnees (ne pas modifier)
src/               run_pipeline.py + run_checks.py (ne pas modifier)
data/              Donnees generees -- unique a vous (gitignore)
db/                nexamart.duckdb -- votre entrepot (gitignore)
docs/              Guides (S00-SETUP, FAQ, exemple annote, formulaires peer-review)
meta/              Empreinte + fingerprint de votre jeu de donnees
validation/        checks.sql canonique execute par make check
tools/instructor/  Outils cote instructeur (ignore pour les etudiants)
.devcontainer/     Config Codespace (Python 3.12 + DuckDB + extensions)
.github/           CI GitHub Classroom (genere + load + check a chaque push)
ai-usage.md        Trace obligatoire de toutes vos interactions IA
```

> Envie d'en savoir plus? Demandez a votre assistant :
> *"Explique-moi a quoi sert chaque dossier dans ce projet."*

---

## References

- Kimball & Ross -- [*The Data Warehouse Toolkit* (3rd ed.)](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/books/data-warehouse-dw-toolkit/)
- Kimball Group -- [Dimensional Modeling Techniques](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/)
- dbt Labs -- [Analytics Engineering Guide](https://www.getdbt.com/analytics-engineering/start-here)
- [DuckDB Documentation](https://duckdb.org/docs/)
