# Glossaire — termes du cours, par ordre alphabétique

Lexique de référence pour étudiants en gestion qui rencontrent un mot
inconnu. Une phrase de définition + un pointeur vers la ressource qui
montre le concept en action.

Pour un traitement **conceptuel** des grands principes Kimball, voir
`docs/kimball-cheatsheet.md`. Ce fichier-ci est un **index de lookup**
à consulter ponctuellement.

---

## A

**Accumulating snapshot fact.** Type de table de faits qui suit un
processus multi-étapes (commande → expédition → livraison) et **se met
à jour** à chaque jalon. Voir `fact_order_pipeline` et
`docs/worked-examples/s09-four-fact-types-walkthrough.md`.

**Additive (mesure).** Mesure numérique qu'on peut sommer sur
**n'importe quel** axe d'analyse. `quantity`, `line_total`. Opposé :
semi-additive, non-additive.

**ai-usage.md.** Fichier à la racine de votre dépôt où vous tenez un
journal de votre usage de l'IA (modèle utilisé, prompt, ce que vous
avez accepté/rejeté). Livrable de transparence, pas d'évaluation de
performance.

**Anti-join.** `LEFT JOIN ... WHERE ... IS NULL` : retourne ce qui
**n'existe pas** dans la table jointe. Usage central des factless fact
tables (ex. "quels produits n'ont reçu aucune exposition ?").

**Autograding.** Workflow GitHub Actions (`.github/workflows/classroom.yml`)
qui lance `make check` sur votre dépôt à chaque `git push`. Les
résultats apparaissent dans l'onglet **Actions** de votre repo.

## B

**Board-brief.** Livrable hebdomadaire d'une à deux pages que vous
rédigez sous `answers/SNN_executive_brief.md`. Répond à la question du
CEO de la semaine avec réponse exécutive, preuve, risques, recommandation.

**Bridge table.** Table qui matérialise une relation M:N entre une
entité et une dimension (ex. `bridge_customer_segment`). Contient
une colonne `weight` dont la somme par entité = 1.0. Voir
`docs/visuals/bridge-m2n.md`.

**Bus matrix.** Grille processus × dimensions qui documente quelles
dimensions sont partagées (conformes) entre tables de faits. Voir
`docs/visuals/bus-matrix.md`.

## C

**Check (validation).** Une requête dans `validation/checks.sql` qui
retourne `PASS`, `FAIL` ou est ignorée en `SKIP`. Lancée par
`make check` / `.\run.ps1 check`.

**Codespace.** Environnement de développement GitHub dans le cloud,
préconfiguré pour GIS805 (Python 3.12 + DuckDB + VS Code dans le
navigateur). Chemin d'entrée recommandé — voir `docs/S00-SETUP.md`.

**Conforming dimension.** Dimension (ex. `dim_date`) partagée par
plusieurs tables de faits **avec exactement les mêmes valeurs**.
Prérequis au drill-across. Voir `docs/visuals/bus-matrix.md`.

**CSV synthétique.** Fichier généré par `make generate` dans
`data/synthetic/team_<seed>/`. Jamais committé (gitignore). Déterministe
par `team_seed`.

## D

**Data warehouse (entrepôt).** Copie dénormalisée, optimisée
analytique, historisée, des données transactionnelles. Dans GIS805 :
fichier `db/nexamart.duckdb`.

**Degenerate dimension.** Identifiant (ex. `order_number`) présent dans
la fact table mais sans dimension dédiée. Sert au grain et au filtrage.

**Dimension.** Table qui fournit le **contexte** d'une mesure : qui,
quoi, où, quand, pourquoi. Colonnes textuelles, peu de lignes, préfixe
`dim_`.

**Dimension conforme.** Voir Conforming dimension.

**Drill-across.** Pattern qui combine deux fact tables **sans les
joindre directement** : on agrège chacune au grain commun, puis on
`FULL JOIN` sur les dimensions conformes. Voir
`docs/visuals/drill-across-pattern.md`.

**DuckDB.** Base analytique embarquée (pas de serveur, un fichier
`.duckdb`). Moteur SQL du cours.

## E

**Effective_from / effective_to.** Colonnes de date qui bornent la
période de validité d'une version SCD2 dans `dim_customer`. Périodes
adjacentes, **jamais chevauchantes**.

**ERD (Entity-Relationship Diagram).** Schéma visuel des tables et de
leurs clés. Voir `docs/visuals/star-schema.md`.

**Executive brief.** Voir Board-brief.

## F

**Fact table.** Table centrale d'un schéma en étoile : contient les
**mesures** (chiffres sommables) et les **FK** vers les dimensions.
Préfixe `fact_`.

**Factless fact table.** Table de faits **sans mesure numérique** ;
chaque ligne atteste qu'un événement s'est produit. Voir
`fact_promo_exposure` et `docs/visuals/promo-exposure-factless.md`.

**FK (Foreign Key).** Clé étrangère qui pointe vers la PK d'une
dimension. Convention Kimball : toujours vers la **surrogate key**
(`*_key`), jamais vers la clé naturelle (`*_id`).

## G

**GitHub Classroom.** Plateforme qui distribue des forks privés du
template à chaque étudiant. Lien :
`https://classroom.github.com/a/1e7AQPN7`.

**Grain.** Phrase en français qui décrit ce qu'**une ligne** d'une fact
table représente. Exemple : "une ligne = une ligne de commande". Règle
d'or : si la phrase contient "et/ou", le grain n'est pas prêt.

**Grain, declaration of.** Première étape de toute modélisation : on
fixe le grain **avant** d'écrire le SQL. Irréversible une fois qu'on a
commencé.

## H

**Head of Data.** Rôle simulé que vous jouez pendant le trimestre.
Vous êtes **individuellement** responsable de l'entrepôt complet de
NexaMart — il n'y a pas d'équipe.

**Hiérarchie (dimension).** Attributs d'une dimension qui s'emboîtent
(province → région → district → magasin dans `dim_store`). Permet les
drill-down.

## I

**Idempotent.** Un script est idempotent s'il produit le même résultat
quand on le relance. `make generate && make load && make check` est
idempotent — c'est la base de la reproductibilité.

**Instructor-solution branch.** Branche du template publiée par
l'instructeur avec le `reference-solution/` complet. Lecture seule pour
les étudiants ; utile pour débloquer après une session.

## J

**JOIN direct entre deux faits.** **Erreur à ne jamais commettre.** Un
`JOIN` direct entre `fact_sales` et `fact_returns` produit un produit
cartésien et gonfle les totaux. Utilisez le drill-across.

**Junk dimension.** Dimension qui regroupe des flags binaires ou des
codes de faible cardinalité (ex. `junk_order_profile`) pour ne pas
polluer la fact table avec des colonnes de statut.

## K

**Kimball.** Ralph Kimball, architecte du **modèle dimensionnel** (star
schema, conforming dimensions, SCD, bus matrix). Tout le vocabulaire
du cours vient de son livre *The Data Warehouse Toolkit* (3e éd.,
non obligatoire — voir `resources` dans `GIS805.yaml`).

## L

**Lab guide (PDF/MD).** Guide imprimable de chaque séance, généré par
`scripts/build_lab_md.py` et `src/pipeline/studio_guide.py`. Contient
la question CEO, le plan, la rubric, le chrono.

**LEFT JOIN.** Jointure qui préserve toutes les lignes de la table de
gauche, y compris celles sans correspondance à droite. Souvent utilisé
pour l'anti-join (`... WHERE t2.id IS NULL`).

## M

**Make.** Outil Unix qui lance les cibles du `Makefile`
(`make generate`, `make load`, `make check`, `make clean`). Sur
Windows : utilisez `.\run.ps1 <cible>` (équivalent).

**Membre inconnu (`-1`).** Ligne spéciale d'une dimension avec
`*_key = -1` qui absorbe les FK `NULL` des faits. Permet de garder
`FK_NOT_NULL` à PASS sans perdre de lignes.

**Mini-dimension.** Voir SCD Type 4.

**Moodle UdeS.** Plateforme institutionnelle de communication du cours.
Les invitations Classroom, annonces et évaluations y passent.

## N

**Natural key (`*_id`).** Identifiant qui vient du système source
(`customer_id = 'CUS-00042'`). Stable côté métier, mais change parfois
→ on ne l'utilise pas comme PK dans les faits.

**Non-additive (mesure).** Mesure qu'on ne peut **pas** sommer
(ex. un ratio, un pourcentage). Il faut la **recalculer** à partir des
composantes additives.

## P

**Peer review.** Trois revues par les pairs (après S04, S09, S11) où
vous lisez le code et les briefs d'un collègue pour apprendre d'autres
modélisations. Pas une évaluation croisée.

**Periodic snapshot fact.** Type de table de faits qui photographie un
état à intervalles réguliers (ex. `fact_inventory_snapshot`, une ligne
par produit × magasin × jour). Mesures **semi-additives**.

**Pipeline.** `src/run_pipeline.py` : le script orchestrateur qui
(1) charge les CSV, (2) exécute les `.sql` dans l'ordre
`staging → dims → facts`, (3) rapporte les tables créées.

**PK (Primary Key).** Clé primaire unique d'une dimension. Convention
Kimball : surrogate key (`*_key`, entier auto-incrémenté).

## R

**RECONCILE (check).** Vérification que deux totaux calculés par deux
chemins différents concordent (ex. somme de `fact_sales.line_total` vs
somme de `fact_budget.target_revenue` au même grain). Détecte les fuites
de lignes dans les jointures.

**Reference solution.** Implémentation complète du warehouse, maintenue
par l'instructeur dans un dépôt privé séparé. Sert de source de vérité
pour la correction, pas de copier-coller pour vous.

**Role-playing dimension.** Même dimension (typiquement `dim_date`)
jointe plusieurs fois dans une même fact avec des alias différents
(`order_date`, `ship_date`, `delivery_date`). Voir
`docs/worked-examples/s07-role-playing-dates-walkthrough.md`.

## S

**SCD (Slowly Changing Dimension).** Stratégie pour gérer les
changements d'attributs dans les dimensions. Cinq types (1, 2, 3, 4, 6)
— voir `docs/kimball-cheatsheet.md` et `docs/visuals/scd-type2-before-after.md`.

**SCD Type 1.** UPDATE écrase l'ancienne valeur. Utilisé pour les
corrections ou les attributs non historisés.

**SCD Type 2.** Ferme la ligne courante (`effective_to`, `is_current = FALSE`),
ouvre une nouvelle ligne. Défaut raisonnable pour les attributs analytiques.

**SCD Type 3.** Ajoute une colonne `previous_*` pour garder **une seule**
transition. Usage rare.

**SCD Type 4 (mini-dimension).** Sort les attributs volatiles
(fréquence, récence) dans une dimension séparée avec sa propre clé,
pour ne pas exploser le nombre de versions de la dimension principale.

**SCD Type 6.** Hybride 1 + 2 + 3 : on historise **et** on garde la
valeur courante dans une colonne à part. Quand l'analyste veut les deux.

**Semi-additive (mesure).** Mesure qu'on peut sommer sur certains axes
mais pas sur le **temps** (ex. `units_on_hand`). Utilisez `AVG` ou une
date de référence.

**Snapshot fact.** Voir Periodic snapshot fact et Accumulating snapshot fact.

**Staging (`sql/staging/`).** Zone de transformation intermédiaire
entre `raw_*` et `dim_*/fact_*`. Pertinent à partir de S06 quand on
intègre plusieurs systèmes sources.

**Star schema (schéma en étoile).** Fact table au centre, dimensions
autour, reliées par des surrogate keys. Voir
`docs/visuals/star-schema.md`.

**Surrogate key (`*_key`).** Entier arbitraire auto-incrémenté, PK
canonique dans l'entrepôt. Stable, compact, rapide à joindre. Opposé :
natural key.

## T

**Team seed.** Entier déterministe calculé depuis votre username GitHub
(`scripts/datagen/_compute_seed.py`). Garantit que chaque étudiant
travaille sur un jeu de données unique mais reproductible.

**Transaction fact.** Type de table de faits qui enregistre un
événement discret (`fact_sales`, `fact_returns`). Mesures additives.

## U

**UTF-8 sans BOM.** Encodage obligatoire des fichiers `.sql` du dépôt.
Un BOM invisible en tête de fichier fait planter `run_pipeline.py`.

## V

**Validation (`validation/checks.sql`).** Fichier qui contient tous les
checks institutionnels du cours (existence, cardinalité, unicité,
grain, FK, SCD2, bridge). Lancé par `src/run_checks.py`.

## W

**Weight (bridge).** Colonne d'un bridge qui réparit la contribution
d'une entité entre ses valeurs de dimension. Invariant :
`SUM(weight) = 1.0` par entité. Sans cette colonne, les totaux sont
gonflés par le nombre de versions.

**Workflow (GitHub Actions).** Fichier YAML dans `.github/workflows/`
qui définit un pipeline CI. Celui du cours :
`build-lab-pdfs.yml` (miroir vers le repo étudiant) et
`classroom.yml` (autograding).
