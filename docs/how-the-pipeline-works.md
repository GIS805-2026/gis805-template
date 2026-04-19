# Comment `run_pipeline.py` fonctionne

Vous n'êtes pas censé modifier `src/run_pipeline.py` — c'est un
orchestrateur donné. Mais vous devez comprendre ce qu'il fait pour
débuguer vos propres SQL quand quelque chose cloche.

Ce document parcourt le fichier section par section, en expliquant **à
quoi chaque bloc sert** et **pourquoi il est écrit de cette façon**.

## Vue d'ensemble

`make load` appelle :

```bash
python src/run_pipeline.py
```

Qui fait trois choses, dans l'ordre :

1. Connecte à `db/nexamart.duckdb` (crée le fichier si besoin).
2. Charge tous vos CSVs sous `data/synthetic/` comme tables `raw_*`.
3. Exécute alphabétiquement les fichiers `.sql` dans `sql/staging/`,
   puis `sql/dims/`, puis `sql/facts/`.

Le but : partir de CSVs sur disque, arriver à un entrepôt dimensionnel
dans un seul fichier DuckDB. Répétable. Idempotent.

## Section 1 — Imports et constantes

```python
ROOT = Path(__file__).resolve().parent.parent
DB_PATH = ROOT / "db" / "nexamart.duckdb"
DATA_DIR = ROOT / "data" / "synthetic"
SQL_DIRS = [
    ROOT / "sql" / "staging",
    ROOT / "sql" / "dims",
    ROOT / "sql" / "facts",
]
```

**Ce que ça dit.** Trois chemins absolus calculés depuis l'emplacement
du script, pas depuis le répertoire courant. Donc `make load` marche
peu importe où vous êtes dans le dépôt.

**Ce que ça implique pour vous.** Si vous créez un dossier
`sql/transformations/`, il ne sera **pas** exécuté — seuls les trois
noms ci-dessus comptent. Collez vos fichiers dans `sql/staging/`,
`sql/dims/` ou `sql/facts/`.

## Section 2 — Trouver les CSVs

```python
def find_csvs(data_dir: Path) -> list[tuple[str, Path]]:
    tables: dict[str, Path] = {}
    for csv_path in sorted(data_dir.rglob("*.csv")):
        stem = csv_path.stem                       # "dim_date"
        table_name = f"raw_{stem}"                 # "raw_dim_date"
        tables[table_name] = csv_path
    return list(tables.items())
```

**Ce que ça dit.** Tous les `.csv` sous `data/synthetic/`, peu importe
la profondeur (shared, s02, s03, …), deviennent des tables `raw_*`.

**Règle de nommage.** Le nom de la table = `raw_` + nom du fichier sans
extension. `dim_customer.csv` → `raw_dim_customer`.

**Piège.** Si S02 et S06 produisent tous deux `fact_sales.csv`, **la
dernière écriture gagne** (l'ordre alphabétique des chemins les
départage : `s02/fact_sales.csv` avant `s06/fact_sales.csv`).

## Section 3 — Charger chaque CSV

```python
def load_csvs(con, csvs):
    for table_name, csv_path in csvs:
        con.execute(f"DROP TABLE IF EXISTS {table_name}")
        con.execute(
            f"CREATE TABLE {table_name} AS "
            f"SELECT * FROM read_csv_auto('{csv_path.as_posix()}')"
        )
```

**`DROP TABLE IF EXISTS`.** Rend le script idempotent. Vous pouvez
relancer `make load` autant de fois que vous voulez sans erreur "table
already exists".

**`read_csv_auto`.** Fonction DuckDB qui devine les types depuis les
premières lignes. C'est rapide et fonctionne pour 95 % des cas. Si vous
voyez un type incorrect (ex. un `date_key` lu comme VARCHAR), passez
par une transformation en staging.

## Section 4 — Exécuter les SQL

```python
def execute_sql_dir(con, sql_dir):
    for sql_file in sorted(sql_dir.glob("*.sql")):
        sql = sql_file.read_text(encoding="utf-8")
        if sql.strip():
            try:
                con.execute(sql)
                print(f"  OK {sql_file.relative_to(ROOT)}")
            except duckdb.Error as e:
                print(f"  FAIL {sql_file.relative_to(ROOT)} -- {e}")
```

**Ordre alphabétique.** `dim_customer.sql` avant `dim_product.sql`
avant `fact_sales.sql`. Votre SQL doit être écrit dans un ordre
compatible avec cet ordre — si `fact_sales.sql` a besoin de
`dim_customer`, tant mieux, `dim_customer.sql` s'exécute d'abord.

**Astuce de tri.** Pour forcer un ordre spécifique, préfixez par un
numéro : `01_dim_date.sql`, `02_dim_customer.sql`, `03_fact_sales.sql`.
Alphabétique + numérique = déterministe.

**Un FAIL n'arrête pas le pipeline.** Le script continue avec les
fichiers suivants. Regardez toujours la sortie complète avant de
conclure.

## Section 5 — Rapport final

```python
def report(con):
    tables = con.execute(
        "SELECT table_name FROM information_schema.tables "
        "WHERE table_schema = 'main' ORDER BY table_name"
    ).fetchall()
    for (tbl,) in tables:
        count = con.execute(f"SELECT COUNT(*) FROM {tbl}").fetchone()[0]
        print(f"  {tbl:<40s} {count:>8,} rows")
```

Affiche toutes les tables et leur cardinalité. C'est votre premier
sanity check : comparez avec
[`docs/expected-warehouse.md`](expected-warehouse.md).

Si une table attendue est absente, c'est que son `.sql` a échoué (un
FAIL en section 4) ou qu'il n'existe pas encore.

## Comment déboguer un FAIL

1. Identifier le fichier fautif dans la sortie : `FAIL sql/dims/dim_customer.sql -- ...`
2. Ouvrir ce fichier dans VS Code.
3. Copier son contenu dans une cellule SQLTools connectée à
   `db/nexamart.duckdb`.
4. Exécuter morceau par morceau. Le premier morceau qui échoue est
   votre coupable.
5. Demander à votre assistant : *"voici mon SQL, voici l'erreur
   DuckDB exacte, corrige et explique."*
6. Corriger le fichier, relancer `make load`.

## Pourquoi ce n'est pas à vous d'écrire

Deux raisons pédagogiques :

1. **Le SQL est votre livrable, l'orchestration n'en est pas un.**
   Dans un vrai entrepôt, l'orchestration est gérée par dbt, Airflow,
   ou un service cloud — pas par un script maison. Le skeleton
   Python qu'on vous donne imite ce découpage.
2. **Vous gagnez 3-4 heures par sprint** en n'ayant pas à débuguer
   des imports `duckdb` ou des chemins relatifs. Ce temps va au SQL
   et au brief exécutif, qui sont ce qu'on évalue.

## Si vous voulez vraiment comprendre plus en profondeur

Demandez à votre assistant IA :

> Explique-moi la différence entre `read_csv_auto` de DuckDB et
> `COPY ... FROM 'file.csv'`. Dans quel cas l'un est préférable à
> l'autre ?

ou

> Propose une version de `run_pipeline.py` qui afficherait un
> message d'erreur plus lisible quand un fichier SQL échoue — sans
> changer la logique.

Ces deux questions sont hors-curriculum mais excellentes pour
consolider la compréhension.
