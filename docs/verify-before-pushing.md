# Vérifier votre travail avant de pousser

Avant chaque commit qui ferme une session, validez localement que votre
travail est correct. Ces trois commandes prennent moins de deux minutes.

## La boucle de vérification

```bash
# 1. Régénérer vos CSVs depuis zéro (optionnel, au premier démarrage)
make generate

# 2. Charger les CSVs dans DuckDB et exécuter tous vos SQL dims/facts
make load

# 3. Vérifier intégrité et contraintes
make check
```

Sur Windows PowerShell, remplacez `make X` par `.\run.ps1 X`.

## Ce que chaque commande doit afficher

### `make load`

Un résumé des tables `raw_*` chargées puis, pour chaque fichier `.sql`
dans `sql/staging/`, `sql/dims/`, `sql/facts/` :

```
  OK sql/dims/dim_customer.sql
  OK sql/dims/dim_product.sql
  ...
  OK sql/facts/fact_sales.sql
```

Un `FAIL sql/...` signale une erreur SQL dans ce fichier. Ouvrez-le, lisez
le message, corrigez, relancez. **Ne continuez pas** tant que tous les
fichiers sont `OK`.

### `make check`

Trois colonnes : `[PASS/FAIL/SKIP] check_type detail result`. L'objectif :

- Aucun `[FAIL]`
- Les `[SKIP]` sont **normaux** pour les checks de sessions futures
  (ex. `BRIDGE_WEIGHT` est SKIP avant S08 parce que la table n'existe pas)

Le résultat complet est aussi écrit dans `validation/results/check_results.txt`
(ignoré par git — c'est un artefact local).

## Si un check échoue

1. Lisez le message dans la colonne `result`.
2. Demandez à votre assistant IA :

```
Mon check "FK_NOT_NULL fact_sales.product_id" renvoie FAIL.
Voici le SQL de mon fact_sales.sql : [collez le code].
Qu'est-ce qui cloche ?
```

3. Corrigez, relancez `make load && make check`.
4. Seulement ensuite, `git commit` + `git push`.

## Après le push

GitHub Classroom rejoue les mêmes commandes via `.github/workflows/classroom.yml`
dans un environnement propre. Si `make check` passe chez vous mais échoue
sur GitHub, c'est presque toujours l'un de :

- Un fichier modifié non commité (faites `git status` pour vérifier).
- Un chemin absolu codé en dur (interdit — utilisez des chemins relatifs
  depuis la racine du repo).
- Un fichier CSV oublié dans `data/synthetic/` (normalement ignoré par
  git, donc regénéré par CI).

## Règle d'or

Si votre brief exécutif cite un chiffre, ce chiffre doit être reproductible
par une requête dans `sql/checks/`. Le correcteur rejoue votre évidence.
Pas de chiffre non-sourcé.
