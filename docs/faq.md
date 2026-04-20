# FAQ — GIS805 NexaMart

> **Vous avez un message d'erreur précis ?** Allez directement à
> [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) — il est organisé par symptôme.
> Cette FAQ répond aux questions *pourquoi* ; le troubleshooting répond
> aux questions *comment débloquer*.

## 1. Pourquoi ne pas simplement créer des vues SQL sur le système opérationnel ?

Les vues résolvent le problème de complexité, mais pas celui de performance ni de stabilité.
Une vue sur un ERP en production consomme les mêmes ressources que la requête sous-jacente.
De plus, tout changement de schéma ERP casse la vue.

L'entrepôt **isole** les analyses des systèmes sources : on copie, on transforme, on historise.
Le système opérationnel reste disponible pour les opérations quotidiennes.

## 2. Est-ce que toutes les entreprises ont un entrepôt de données ?

Non. Les PME travaillent souvent directement sur leurs systèmes opérationnels ou utilisent
des outils BI connectés aux bases sources.

Mais dès qu'une organisation a besoin de **croiser des données de plusieurs systèmes** ou de
**conserver l'historique**, un entrepôt devient nécessaire. C'est un signe de maturité analytique.

## 3. Est-ce qu'on travaille en équipe ?

Non. Chaque étudiant est **individuellement** responsable de l'entrepôt complet de NexaMart.
Vous êtes le seul Head of Data — vous construisez les 5 tables de faits, les dimensions,
et la documentation.

Trois **revues par les pairs** (après S04, S09 et S11) permettent d'apprendre des modèles
de vos collègues, mais le travail et l'évaluation sont individuels.

## 4. Pourquoi DuckDB et pas Snowflake ou BigQuery ?

DuckDB est gratuit, embarqué, et ne nécessite aucune infrastructure cloud.
Les concepts qu'on apprend — étoile, grain, SCD, drill-across — s'appliquent
**identiquement** sur n'importe quel moteur.

On élimine la complexité d'infrastructure pour se concentrer sur la **modélisation**.
Votre fichier `db/nexamart.duckdb` est votre entrepôt complet, portable et versionnable.

## Erreurs fréquentes

Cette section grandit avec les questions récurrentes du forum. Cherchez
votre message d'erreur ici avant de demander au groupe.

### `ERROR: No CSVs found in data/synthetic/`

Votre jeu de données n'a pas encore été généré. Lancez :

```bash
make generate          # Mac/Linux
.\run.ps1 generate     # Windows PowerShell
```

### `make: command not found` (Windows)

`make` n'est pas installé par défaut sur Windows. Utilisez le script
PowerShell équivalent :

```powershell
.\run.ps1 generate
.\run.ps1 load
.\run.ps1 check
```

Ou passez au Codespace (Chemin A de `docs/S00-SETUP.md`), où `make`
fonctionne tout seul.

### `duckdb.CatalogException: Table ... does not exist`

Votre SQL dans `sql/facts/` ou `sql/views/` référence une dimension qui
n'a pas encore été créée. Cause habituelle : vous avez écrit
`sql/facts/fact_sales.sql` avant `sql/dims/dim_product.sql`.

`run_pipeline.py` exécute les dossiers dans l'ordre `staging → dims → facts`,
**puis alphabétiquement** à l'intérieur. Vérifiez que chaque dimension
référencée existe et que son fichier `.sql` est bien dans `sql/dims/`.

### `make check` affiche `[SKIP] MISSING_TABLE`

Normal si le check concerne une table d'une séance future (ex. `fact_returns`
avant S06). Les SKIP ne comptent pas comme des FAIL. Regardez seulement les
FAIL pour la séance courante.

### `make check` passe localement mais échoue sur GitHub Classroom

Presque toujours l'un de :

- **Fichier non commité.** `git status` doit être vide avant `git push`.
- **Chemin absolu codé en dur.** Utilisez des chemins relatifs depuis la
  racine du dépôt (ex. `data/synthetic/...`, pas
  `C:/Users/alice/gis805/...`).
- **Caractères non-UTF-8 dans un `.sql`.** Sauvegardez en UTF-8 sans BOM.

### `Permission denied (publickey)` au clone

Vous n'avez pas encore accepté l'assignment Classroom, ou la configuration
SSH de GitHub n'est pas en place. Le plus simple : clonez via HTTPS avec
votre Personal Access Token, ou ouvrez un Codespace (zéro configuration).

### Mon Codespace prend 5 minutes à démarrer

Le premier démarrage compile l'image devcontainer. Les ouvertures
suivantes sont instantanées tant que vous ne supprimez pas le Codespace.
Si vous atteignez votre quota mensuel (60 h avec le Student Pack),
passez en local (Chemin B de `docs/S00-SETUP.md`).

### Mon assistant IA écrit un SQL que je ne comprends pas

C'est le signal d'alarme du cours. Ne committez **jamais** du SQL que
vous ne pouvez pas expliquer ligne par ligne à un correcteur. Demandez
à l'assistant : *"explique-moi chaque clause de cette requête comme si
j'étais un étudiant d'affaires."* Si la réponse ne vous éclaire pas, le
SQL est probablement incorrect ou trop sophistiqué pour le besoin.

### Le check `BRIDGE_WEIGHT` échoue avec `SUM(weight) ≠ 1.0`

Votre logique de normalisation divise par le mauvais total. Commun :
diviser par le total global au lieu du total **par client**. Relisez
`sql/templates/05_bridge_m2m.sql` et le prompt du lab S08.
