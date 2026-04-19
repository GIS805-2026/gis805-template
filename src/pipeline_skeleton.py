#!/usr/bin/env python3
"""
pipeline_skeleton.py -- Annotated walkthrough of run_pipeline.py.

This file is PURE EDUCATION. It does the same three things as
``run_pipeline.py`` but with extensive inline comments aimed at students
who want to peek under the hood without being programmers.

You can run it safely alongside the real pipeline -- it writes to a
SEPARATE database (``db/nexamart_skeleton.duckdb``) so nothing you built
with ``make load`` gets touched:

    python src/pipeline_skeleton.py

After it runs, compare ``db/nexamart.duckdb`` (your real warehouse) and
``db/nexamart_skeleton.duckdb`` (what the skeleton produced). They should
have the same ``raw_*`` tables. The skeleton does NOT execute any of the
student SQL files -- it stops after loading CSVs, because the point is
to show where and HOW run_pipeline.py reads your data, not to replace it.

When you're comfortable, read ``src/run_pipeline.py`` next. It is this
same logic, without the commentary. No new concepts -- same 3 steps.

----------------------------------------------------------------------
The 3 steps, at a glance
----------------------------------------------------------------------
  1. OPEN a DuckDB file on disk (create if missing).
  2. FIND every CSV under data/synthetic/ and load each one into a
     table named ``raw_<filename-without-ext>``.
  3. LIST what ended up in the database and print row counts.

If you can explain these three steps to someone else in plain French,
you can explain what happens when you type ``make load``.
"""
from __future__ import annotations

# stdlib only -- same imports as run_pipeline.py
import sys
from pathlib import Path

# DuckDB is the embedded analytical database we use for the whole course.
# It's a single .duckdb file on disk with a full SQL engine inside.
try:
    import duckdb
except ImportError:
    print("ERROR: duckdb not installed. Run:  pip install duckdb")
    sys.exit(1)


# ----------------------------------------------------------------------
# File-system conventions (identical to run_pipeline.py)
# ----------------------------------------------------------------------
# ROOT points at the folder that contains THIS file's parent -- i.e. the
# repo root (because this file is in src/). All other paths are built
# from ROOT so the script works whether you run it from the repo root
# or from inside src/.
ROOT = Path(__file__).resolve().parent.parent

# The SKELETON writes to a *different* file than run_pipeline.py so the
# two can coexist. If you want to wipe it, just delete this file.
DB_PATH = ROOT / "db" / "nexamart_skeleton.duckdb"

# The data folder is populated by ``make generate`` (or
# ``scripts/datagen/gen_all.py`` directly). One CSV per dimension/fact,
# organized by session (s01/, s02/, ...).
DATA_DIR = ROOT / "data" / "synthetic"


# ----------------------------------------------------------------------
# Step 1 -- CSV discovery
# ----------------------------------------------------------------------
def find_csvs(data_dir: Path) -> list[tuple[str, Path]]:
    """Walk data_dir recursively and return (table_name, csv_path) pairs.

    Table naming convention:
        data/synthetic/team_7/shared/dim_date.csv   ->  raw_dim_date
        data/synthetic/team_7/s02/fact_sales.csv    ->  raw_fact_sales

    If two sessions happen to produce the same filename (e.g. a later
    session regenerates fact_sales with more rows), the LATER one wins
    because we sort by path and let the later key overwrite the earlier
    one in the dict.
    """
    if not data_dir.exists():
        return []

    tables: dict[str, Path] = {}
    for csv_path in sorted(data_dir.rglob("*.csv")):
        # stem = filename without extension. "dim_date.csv" -> "dim_date"
        table_name = f"raw_{csv_path.stem}"
        tables[table_name] = csv_path
    return list(tables.items())


# ----------------------------------------------------------------------
# Step 2 -- Load each CSV as a DuckDB table
# ----------------------------------------------------------------------
def load_csvs(con: duckdb.DuckDBPyConnection, csvs: list[tuple[str, Path]]) -> None:
    """For each (name, path) pair, (re)create the table from the CSV.

    DuckDB's ``read_csv_auto`` is the magic here: it sniffs the delimiter,
    guesses column types, and handles quoting. For a production warehouse
    you would be stricter (declare schemas explicitly), but for a student
    lab the auto-detection is correct 99% of the time.
    """
    for table_name, csv_path in csvs:
        # DROP before CREATE so re-running is idempotent.
        con.execute(f"DROP TABLE IF EXISTS {table_name}")

        # The as_posix() call makes the path use forward slashes even on
        # Windows, which DuckDB's SQL parser prefers.
        con.execute(
            f"CREATE TABLE {table_name} AS "
            f"SELECT * FROM read_csv_auto('{csv_path.as_posix()}')"
        )

        # Fetch one value (COUNT) as a sanity check / progress indicator.
        count = con.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
        rel = csv_path.relative_to(ROOT)
        print(f"  {table_name:<40s} {count:>8,} rows   <- {rel}")


# ----------------------------------------------------------------------
# Step 3 -- Report what landed in the database
# ----------------------------------------------------------------------
def report(con: duckdb.DuckDBPyConnection) -> None:
    """Print every table in the 'main' schema plus its row count.

    ``information_schema.tables`` is the standard SQL catalog view. Every
    serious database ships it. It's how you ask 'what tables do I have?'
    in portable SQL.
    """
    tables = con.execute(
        "SELECT table_name FROM information_schema.tables "
        "WHERE table_schema = 'main' ORDER BY table_name"
    ).fetchall()

    print()
    print("=" * 60)
    print(f"  {len(tables)} tables in {DB_PATH.relative_to(ROOT)}")
    print("=" * 60)
    for (tbl,) in tables:
        count = con.execute(f"SELECT COUNT(*) FROM {tbl}").fetchone()[0]
        print(f"  {tbl:<40s} {count:>8,} rows")
    print()


# ----------------------------------------------------------------------
# Putting it together
# ----------------------------------------------------------------------
def main() -> None:
    # Make sure db/ exists so DuckDB can create its file there.
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)

    # This call either OPENS the existing .duckdb file or CREATES a new
    # one. There is no server -- DuckDB is in-process.
    con = duckdb.connect(str(DB_PATH))

    # 1. Find CSVs
    csvs = find_csvs(DATA_DIR)
    if not csvs:
        print(f"ERROR: No CSVs found in {DATA_DIR.relative_to(ROOT)}/")
        print("       Run 'make generate' (or .\\run.ps1 generate) first.")
        con.close()
        sys.exit(1)

    print(f"\n-- Loading {len(csvs)} CSVs into {DB_PATH.name} --\n")

    # 2. Load them as raw_* tables
    load_csvs(con, csvs)

    # 3. Report. The real run_pipeline.py also executes sql/staging/,
    #    sql/dims/, sql/facts/ here. The skeleton deliberately stops at
    #    reporting so you can see exactly what state the DB is in BEFORE
    #    any student SQL runs.
    report(con)

    con.close()
    print(f"Skeleton done. Compare with db/nexamart.duckdb (built by 'make load').")


if __name__ == "__main__":
    main()
