# Troubleshooting — par symptôme

Cherchez votre **symptôme exact** (message d'erreur, comportement
observé) dans la table des matières ci-dessous, puis sautez directement
à la section. Plus rapide que relire la FAQ en entier.

La FAQ (`docs/faq.md`) répond aux questions *pourquoi* ; ce document
répond aux questions *comment débloquer* une situation précise.

---

## Table des matières

- **Installation / Setup**
  - [`make: command not found`](#make-command-not-found)
  - [`python: command not found` ou la mauvaise version](#python-command-not-found)
  - [Codespace met > 5 min à démarrer](#codespace-lent)
  - [`duckdb` non installé au premier run](#duckdb-non-installe)

- **Génération de données**
  - [`ERROR: No CSVs found in data/synthetic/`](#no-csvs-found)
  - [`git push` rejette à cause d'un `.csv` trop gros](#csv-trop-gros)
  - [Données identiques à celles d'un collègue](#seeds-identiques)

- **Chargement du pipeline**
  - [`duckdb.CatalogException: Table ... does not exist`](#table-does-not-exist)
  - [`run_pipeline.py` saute mon fichier `.sql`](#sql-saute)
  - [Encoding error / caractères étrangers dans les logs](#encoding)

- **Validation / make check**
  - [`[SKIP] MISSING_TABLE`](#skip-missing-table)
  - [`[FAIL] DUPLICATE_GRAIN`](#fail-duplicate-grain)
  - [`[FAIL] SCD2_OVERLAP`](#fail-scd2-overlap)
  - [`[FAIL] BRIDGE_WEIGHT_NOT_ONE`](#fail-bridge-weight)
  - [`[FAIL] FK_NOT_NULL`](#fail-fk-not-null)
  - [`make check` passe en local mais échoue sur Classroom](#local-ok-classroom-fail)

- **Git / GitHub Classroom**
  - [`Permission denied (publickey)` au clone](#permission-denied)
  - [L'autograding tourne dans le vide sur le dernier commit](#autograding-silent)
  - [J'ai commité mon `.duckdb` ou mes `.csv` par erreur](#committed-binaries)

- **SQL / modélisation**
  - [Mes totaux sont 2x ou 3x trop grands](#totaux-trop-grands)
  - [`SUM(weight) ≠ 1.0` par client](#sum-weight-off)
  - [Rapport vide à cause d'un `INNER JOIN`](#rapport-vide)

- **Erreurs SQL fréquentes pour débutants**
  - [`column must appear in the GROUP BY clause`](#column-group-by)
  - [`Binder Error: ambiguous reference to column name`](#ambiguous-column)
  - [`Catalog Error: Table ... does not exist` dans une requête](#table-not-found-query)
  - [`Parser Error: syntax error at or near`](#syntax-error)
  - [Mon résultat est `NULL` au lieu d'un chiffre](#result-null)
  - [Ma requête retourne 0 lignes alors que la table n'est pas vide](#zero-rows)

---

## Installation / Setup

### <a id="make-command-not-found"></a>`make: command not found`

**Symptôme.** `make generate` affiche `make: command not found` (ou
`'make' n'est pas reconnu` sous PowerShell).

**Cause.** Windows n'a pas `make` dans son PATH par défaut.

**Fix.** Trois options, par ordre de simplicité :

1. Utilisez l'équivalent PowerShell : `.\run.ps1 generate`, `.\run.ps1 load`,
   `.\run.ps1 check`. Appelle les mêmes scripts Python que `make`.
2. Passez au Codespace (Chemin A de `docs/S00-SETUP.md`) — `make` y est
   préinstallé.
3. Installez `make` via `choco install make` ou `winget install GnuWin32.Make`,
   puis redémarrez votre terminal.

### <a id="python-command-not-found"></a>`python: command not found` ou mauvaise version

**Symptôme.** `python --version` affiche `command not found` ou une
version < 3.12.

**Fix.**

- **Codespace :** rien à faire, Python 3.12 est déjà là.
- **Local :** installez Python 3.12 depuis
  [python.org](https://www.python.org/downloads/) (cochez
  "Add to PATH" à l'installation) et relancez un nouveau terminal.
- **Windows + plusieurs Pythons :** utilisez `py -3.12 -V` pour cibler la
  bonne version.

### <a id="codespace-lent"></a>Codespace met > 5 minutes à démarrer

**Symptôme.** Après `Create codespace`, l'écran reste bloqué sur
"Building image…".

**Cause.** Premier démarrage → compilation du devcontainer.

**Fix.** Attendre. Les redémarrages suivants sont instantanés tant que
le Codespace n'est pas supprimé. Si > 15 min, rafraîchissez la page
GitHub — le Codespace continue en arrière-plan.

### <a id="duckdb-non-installe"></a>`ModuleNotFoundError: No module named 'duckdb'`

**Symptôme.** `make load` plante avec ce message.

**Fix.** `pip install duckdb`. Si le Codespace vient d'être créé et que
`pip` n'est pas disponible, lancez `python -m pip install duckdb`.

---

## Génération de données

### <a id="no-csvs-found"></a>`ERROR: No CSVs found in data/synthetic/`

**Cause.** `make load` cherche les CSVs mais vous n'avez pas encore
lancé `make generate`.

**Fix.**

```bash
make generate          # Mac / Linux / Codespace
.\run.ps1 generate     # Windows PowerShell
```

Puis relancez `make load`. Le générateur est déterministe par
`team_seed` — toujours les mêmes chiffres pour votre username.

### <a id="csv-trop-gros"></a>`git push` rejette à cause d'un `.csv` trop gros

**Symptôme.** `remote: error: File data/synthetic/team_7/s02/fact_sales.csv
is 105.23 MB; this exceeds GitHub's file size limit of 100.00 MB`.

**Cause.** Vous avez commité un CSV généré. Ils sont déjà dans
`.gitignore` — vérifiez que vous êtes à la racine du dépôt.

**Fix.**

```bash
git rm --cached data/synthetic/team_7/s02/fact_sales.csv
git commit -m "remove generated csv"
git push
```

Si le CSV est dans plusieurs commits, utilisez
`git filter-branch` ou [BFG](https://rtyley.github.io/bfg-repo-cleaner/).
Demandez de l'aide au forum avant — c'est destructeur.

### <a id="seeds-identiques"></a>Données identiques à celles d'un collègue

**Symptôme.** Deux étudiants ont exactement le même `fact_sales.csv`.

**Cause.** Votre `team_seed` est calculé depuis votre username GitHub.
Si vous avez cloné le dépôt d'un autre étudiant ou copié un CSV, vous
travaillez sur son jeu de données.

**Fix.** Depuis **votre** Classroom invitation, acceptez pour créer
**votre** fork. `make clean && make generate` régénère le bon jeu.

---

## Chargement du pipeline

### <a id="table-does-not-exist"></a>`duckdb.CatalogException: Table ... does not exist`

**Symptôme.** `run_pipeline.py` plante sur un `sql/facts/*.sql` qui
référence une dimension.

**Cause.** La dimension n'est pas encore construite, ou son fichier est
dans le mauvais dossier.

**Fix.** `run_pipeline.py` exécute les dossiers **dans l'ordre**
`staging → dims → facts`, puis **alphabétiquement** à l'intérieur.

Vérifiez que :

- `sql/dims/dim_<X>.sql` existe.
- La FK du fait (`customer_key`) pointe vers la bonne colonne de la
  dimension (`dim_customer.customer_key`, pas `customer_id`).
- Vous n'avez pas écrit `fact_*.sql` dans `sql/dims/` par erreur.

### <a id="sql-saute"></a>`run_pipeline.py` saute mon fichier `.sql`

**Symptôme.** Le script termine sans erreur mais votre dim/fact n'est
pas dans le `.duckdb`.

**Cause.** Fichier avec une extension non reconnue (`.SQL` majuscule,
`.sql.bak`, etc.) ou permissions en lecture seule.

**Fix.** Confirmez l'extension exacte : `ls sql/dims/`. DuckDB est
insensible à la casse des extensions sur macOS/Linux ; `run_pipeline.py`
ne l'est pas — utilisez `.sql` minuscule.

### <a id="encoding"></a>Encoding error / caractères étrangers dans les logs

**Symptôme.** `UnicodeDecodeError` à la lecture d'un `.sql`.

**Cause.** Fichier sauvegardé en UTF-8 **avec BOM** ou en Windows-1252.

**Fix.** Re-sauvegardez en **UTF-8 sans BOM**. Dans VS Code :
barre de statut en bas à droite → cliquez sur `UTF-8 with BOM` → choisissez
`Save with Encoding` → `UTF-8`.

---

## Validation / make check

### <a id="skip-missing-table"></a>`[SKIP] MISSING_TABLE`

**Ce n'est pas une erreur.** Le check concerne une table que vous
n'avez pas encore construite (ex. `fact_returns` avant S05). Les SKIP
sont attendus en début de trimestre et diminuent à chaque séance. Le
trajet A de `tests/test_gis805_trajectories.py` vérifie que le template
vide produit uniquement des SKIP.

**Action requise :** aucune — pour cette séance-ci.

### <a id="fail-duplicate-grain"></a>`[FAIL] DUPLICATE_GRAIN`

**Symptôme.** `Table fact_sales has N duplicate rows on (order_number, sale_line_id)`.

**Cause la plus fréquente.** Votre SCD2 sur `dim_customer` produit des
fenêtres de validité qui se chevauchent. Une vente tombe dans **deux**
versions → la jointure la duplique.

**Fix.** Inspectez :

```sql
SELECT customer_id, effective_from, effective_to, COUNT(*) OVER (PARTITION BY customer_id) AS versions
FROM dim_customer
ORDER BY customer_id, effective_from;
```

Chaque `customer_id` doit avoir des périodes adjacentes **sans
chevauchement** : `effective_to` de la v1 = `effective_from` de la v2 − 1 jour.

### <a id="fail-scd2-overlap"></a>`[FAIL] SCD2_OVERLAP`

**Symptôme.** Même cause que ci-dessus, mais détecté à la source.

**Fix.** Utilisez le pattern *event rollforward* de
`sql/templates/03_scd_type2.sql` : ordonnez les `raw_customer_changes`
par date, et fermez explicitement la version précédente avant d'en
ouvrir une nouvelle. Pas de cross join entre base et changements — c'est
le bug qui a motivé `a4e8e35` dans la reference-solution.

### <a id="fail-bridge-weight"></a>`[FAIL] BRIDGE_WEIGHT_NOT_ONE`

**Symptôme.** `bridge_customer_segment has N customer_ids where SUM(weight) ≠ 1.0`.

**Cause.** Votre logique de normalisation divise par le mauvais total
(ex. total global au lieu du total par client).

**Fix.** Voir `docs/worked-examples/s08-bridge-returns-walkthrough.md`
et `sql/templates/05_bridge_m2m.sql`. Le pattern correct :

```sql
SELECT
  customer_id,
  segment_id,
  segment_contribution / SUM(segment_contribution) OVER (PARTITION BY customer_id) AS weight
FROM raw_customer_segments;
```

Le `OVER (PARTITION BY customer_id)` est non négociable.

### <a id="fail-fk-not-null"></a>`[FAIL] FK_NOT_NULL`

**Symptôme.** `fact_sales has N rows with NULL customer_key`.

**Cause.** Un `LEFT JOIN` au lieu d'un `INNER JOIN`, ou une FK vers une
dimension qui n'a pas de membre inconnu (`-1`) pour absorber les NULL.

**Fix.** Voir
`docs/worked-examples/s07-role-playing-dates-walkthrough.md` — insérez
un membre inconnu dans la dimension, puis remplacez les `NULL` par son
`*_key` au chargement.

### <a id="local-ok-classroom-fail"></a>`make check` passe en local, échoue sur Classroom

Toujours l'un de :

1. **Fichier non commité.** `git status` doit être vide avant `git push`.
   Un `.sql` dans `sql/dims/` que vous oubliez de `git add` ne passe pas
   l'autograding.
2. **Chemin absolu.** Remplacez `C:/Users/alice/gis805/...` par
   `data/synthetic/...` (relatif à la racine).
3. **Différence de seed.** Classroom regénère depuis votre username
   GitHub. Si vous avez édité les CSVs à la main, le check casse.
   Ne modifiez jamais les CSVs — régénérez-les.
4. **Caractères non-UTF-8 dans un `.sql`** (voir plus haut).

---

## Git / GitHub Classroom

### <a id="permission-denied"></a>`Permission denied (publickey)` au clone

**Cause.** SSH non configuré.

**Fix le plus simple :** clonez en HTTPS en vous authentifiant avec un
Personal Access Token. Ou ouvrez un Codespace — auth préconfigurée.

### <a id="autograding-silent"></a>L'autograding ne tourne pas sur mon dernier commit

**Cause.** Le workflow `classroom.yml` ne se déclenche que sur `main`.
Si vous avez poussé sur une branche, Classroom ignore.

**Fix.** `git checkout main && git merge <branche> && git push origin main`.

### <a id="committed-binaries"></a>J'ai commité mon `.duckdb` ou mes `.csv` par erreur

Voir [CSV trop gros](#csv-trop-gros). Même procédure pour les `.duckdb`.
Ces deux familles de fichiers sont **toujours** régénérables à partir
de votre SQL — ne les conservez pas dans Git.

---

## SQL / modélisation

### <a id="totaux-trop-grands"></a>Mes totaux sont 2x ou 3x trop grands

**Cause quasi certaine.** `JOIN` direct entre deux tables de faits, ou
bridge sans multiplication par `weight`.

**Fix.** Voir `docs/worked-examples/s06-drill-across-walkthrough.md`
pour le drill-across, et `docs/worked-examples/s08-bridge-returns-walkthrough.md`
pour le bridge. Règle : **jamais** deux faits dans la même `FROM`.

### <a id="sum-weight-off"></a>`SUM(weight) ≠ 1.0` par client

Voir [`[FAIL] BRIDGE_WEIGHT_NOT_ONE`](#fail-bridge-weight) ci-dessus.

### <a id="rapport-vide"></a>Rapport vide à cause d'un `INNER JOIN`

**Symptôme.** Vous attendiez 500 commandes, votre requête en retourne
120 ou 0.

**Cause.** Un `INNER JOIN` vers une dimension dont certaines FK sont
`NULL` (ex. `ship_date_key` d'une commande non expédiée).

**Fix.** Soit un `LEFT JOIN` si vous voulez voir les NULLs, soit — mieux —
un membre inconnu dans la dimension et remplacement des `NULL` par
son `*_key`. Voir
`docs/worked-examples/s07-role-playing-dates-walkthrough.md`.

---

## Erreurs SQL fréquentes pour débutants

> **Nouveau en SQL ?** Ces erreurs arrivent à tout le monde les premières semaines.
> Ce n'est pas un signe d'échec — c'est le processus d'apprentissage normal.

### <a id="column-group-by"></a>`column must appear in the GROUP BY clause`

**Symptôme.** Vous écrivez un `SELECT` avec un `GROUP BY` et DuckDB refuse
l'exécution avec ce message.

**Cause.** Chaque colonne dans `SELECT` doit être soit :
- listée dans `GROUP BY`, soit
- à l'intérieur d'une fonction d'agrégation (`SUM`, `COUNT`, `AVG`, `MIN`, `MAX`).

**Exemple fautif :**
```sql
SELECT category, region, SUM(line_total) AS revenu
FROM fact_sales
GROUP BY category;
-- ❌ region n'est ni dans GROUP BY ni dans une agrégation
```

**Fix :**
```sql
SELECT category, region, SUM(line_total) AS revenu
FROM fact_sales
GROUP BY category, region;
-- ✅ les deux colonnes sont dans GROUP BY
```

**Règle simple :** si une colonne n'est pas « résumée » (SUM, COUNT...),
elle doit être dans `GROUP BY`.

### <a id="ambiguous-column"></a>`Binder Error: ambiguous reference to column name`

**Symptôme.** Vous avez un `JOIN` entre deux tables qui ont une colonne
du même nom (ex. `category`, `region`, `name`).

**Cause.** DuckDB ne sait pas de quelle table prendre la colonne.

**Fix.** Ajoutez l'alias de la table devant la colonne :
```sql
-- ❌ ambiguë
SELECT category, SUM(line_total)
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY category;

-- ✅ précise
SELECT p.category, SUM(f.line_total)
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category;
```

**Habitude à prendre :** dès que vous avez un `JOIN`, préfixez *toutes*
les colonnes avec l'alias de la table (`f.`, `p.`, `d.`, `s.`).

### <a id="table-not-found-query"></a>`Catalog Error: Table ... does not exist` dans une requête

**Symptôme.** Votre requête échoue parce qu'une table n'existe pas encore.

**Causes possibles :**
1. Faute de frappe dans le nom de la table.
2. Vous n'avez pas encore exécuté `make load` (ou `.\run.ps1 load`).
3. Votre fichier SQL qui crée cette table a une erreur et n'a pas été chargé.

**Fix :**
1. Vérifiez le nom exact : `SHOW TABLES;`
2. Relancez `make load` et regardez s'il y a des erreurs.
3. Si la table manque toujours, vérifiez votre fichier SQL dans `sql/dims/` ou `sql/facts/`.

### <a id="syntax-error"></a>`Parser Error: syntax error at or near`

**Symptôme.** DuckDB refuse votre requête avec une erreur de syntaxe.

**Causes fréquentes :**
- Virgule manquante ou en trop entre les colonnes.
- Parenthèse ouverte mais pas fermée (ou l'inverse).
- Guillemet simple non fermé dans une valeur texte.
- Mot clé mal orthographié (`SELCET`, `FORM`, `GRUOP BY`).

**Fix.** Copiez votre requête et demandez à votre assistant IA :
« Trouve l'erreur de syntaxe dans cette requête SQL et explique-moi
la correction. »

### <a id="result-null"></a>Mon résultat est `NULL` au lieu d'un chiffre

**Symptôme.** Une colonne agrégée (`SUM`, `AVG`) retourne `NULL`.

**Cause.** Si *toutes* les valeurs d'entrée sont `NULL`, l'agrégation
retourne `NULL` (pas 0).

**Fix :** Utilisez `COALESCE` pour remplacer les NULLs :
```sql
SELECT COALESCE(SUM(line_total), 0) AS revenu
FROM fact_sales
WHERE region = 'Mars';
-- Pas de ventes sur Mars → retourne 0 au lieu de NULL
```

### <a id="zero-rows"></a>Ma requête retourne 0 lignes alors que la table n'est pas vide

**Symptôme.** Vous savez que la table contient des données, mais votre
`SELECT` ne retourne rien.

**Causes fréquentes :**
1. **`WHERE` trop restrictif.** Vérifiez vos filtres — peut-être que
   la valeur exacte n'existe pas (majuscule/minuscule, accent, espace).
2. **`INNER JOIN` avec des NULLs.** Si une clé étrangère est `NULL`,
   le `INNER JOIN` élimine cette ligne. Essayez un `LEFT JOIN`.
3. **Table vide.** Lancez `SELECT COUNT(*) FROM ma_table;` pour vérifier.

**Fix rapide :** Enlevez le `WHERE` et les `JOIN` un par un pour trouver
lequel élimine les lignes.

---

## Vous ne trouvez pas votre symptôme ?

1. Recherchez votre message d'erreur textuel dans ce fichier (`Ctrl+F`).
2. Sinon dans `docs/faq.md`.
3. Sinon postez sur le forum de la séance avec : (a) la commande
   lancée, (b) le message complet, (c) le hash du commit concerné
   (`git rev-parse --short HEAD`).
