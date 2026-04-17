#!/usr/bin/env python3
"""
Autograding script for GitHub Classroom.

Runs validation checks against the student's DuckDB database.
Exit code 0 = all required checks pass, 1 = at least one FAIL.

This script is intentionally lenient in early sessions:
- If db/nexamart.duckdb does not exist, it checks for raw CSV files instead.
- Checks are grouped by section; INFO results do not cause failure.
"""

import sys
from pathlib import Path

try:
    import duckdb
except ImportError:
    print("SKIP: duckdb not installed -- cannot run checks")
    sys.exit(0)

DB_PATH = Path("db/nexamart.duckdb")
RAW_DIR = Path("data/synthetic")
CHECKS_SQL = Path("validation/checks.sql")

results = {"pass": 0, "fail": 0, "info": 0, "skip": 0}


def check_files():
    """Check that required non-SQL files exist."""
    required = [
        Path("ai-usage.md"),
    ]
    recommended = [
        Path("meta/dataset_identity.json"),
    ]
    ok = True
    for f in required:
        if f.exists():
            print(f"  PASS  {f}")
            results["pass"] += 1
        else:
            print(f"  FAIL  {f} -- required file missing")
            results["fail"] += 1
            ok = False

    for f in recommended:
        if f.exists():
            print(f"  PASS  {f}")
            results["pass"] += 1
        else:
            print(f"  INFO  {f} -- recommended but not required yet")
            results["info"] += 1
    return ok


def check_raw_csvs():
    """Verify that raw CSV data has been generated."""
    expected = ["dim_customer.csv", "dim_product.csv", "dim_store.csv",
                "dim_channel.csv", "dim_date.csv", "fact_sales.csv"]
    found = 0
    for name in expected:
        # Search recursively (generators put files in team_*/shared/ or team_*/s0*/)
        matches = list(RAW_DIR.rglob(name))
        if matches and matches[0].stat().st_size > 100:
            found += 1
            results["pass"] += 1
            print(f"  PASS  {matches[0]} ({matches[0].stat().st_size:,} bytes)")
        else:
            results["info"] += 1
            print(f"  INFO  {name} -- not found in {RAW_DIR}")
    return found


def check_database():
    """Run SQL checks against the DuckDB database."""
    if not DB_PATH.exists():
        print(f"  SKIP  {DB_PATH} does not exist yet")
        results["skip"] += 1
        return True

    try:
        con = duckdb.connect(str(DB_PATH), read_only=True)
    except Exception as exc:
        print(f"  FAIL  Cannot open {DB_PATH}: {exc}")
        results["fail"] += 1
        return False

    ok = True

    tables = [r[0] for r in con.execute("SHOW TABLES").fetchall()]
    raw_tables = [t for t in tables if t.startswith("raw_")]
    dim_tables = [t for t in tables if t.startswith("dim_")]
    fact_tables = [t for t in tables if t.startswith("fact_")]

    if len(raw_tables) >= 4:
        print(f"  PASS  raw tables: {len(raw_tables)} found")
        results["pass"] += 1
    else:
        print(f"  FAIL  raw tables: only {len(raw_tables)} found (need >= 4)")
        results["fail"] += 1
        ok = False

    if len(dim_tables) >= 1:
        print(f"  PASS  dim tables: {len(dim_tables)} found")
        results["pass"] += 1
    else:
        print(f"  INFO  dim tables: none yet")
        results["info"] += 1

    if len(fact_tables) >= 1:
        print(f"  PASS  fact tables: {len(fact_tables)} found")
        results["pass"] += 1
    else:
        print(f"  INFO  fact tables: none yet")
        results["info"] += 1

    for t in raw_tables:
        try:
            cnt = con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
            if cnt > 0:
                print(f"  PASS  {t}: {cnt:,} rows")
                results["pass"] += 1
            else:
                print(f"  FAIL  {t}: 0 rows")
                results["fail"] += 1
                ok = False
        except Exception as exc:
            print(f"  FAIL  {t}: {exc}")
            results["fail"] += 1
            ok = False

    for t in raw_tables:
        try:
            cols = [r[0] for r in con.execute(f"DESCRIBE {t}").fetchall()]
            id_cols = [c for c in cols if c.endswith("_id")]
            for id_col in id_cols:
                total = con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
                distinct = con.execute(f"SELECT COUNT(DISTINCT {id_col}) FROM {t}").fetchone()[0]
                nulls = con.execute(f"SELECT COUNT(*) FROM {t} WHERE {id_col} IS NULL").fetchone()[0]
                if nulls == 0:
                    results["pass"] += 1
                else:
                    print(f"  FAIL  {t}.{id_col}: {nulls} NULL values")
                    results["fail"] += 1
                    ok = False
        except Exception:
            pass

    con.close()
    return ok


def check_briefs():
    """Check that at least one executive brief has content."""
    briefs_dir = Path("answers")
    if not briefs_dir.exists():
        print(f"  INFO  {briefs_dir}/ not found")
        results["info"] += 1
        return True

    briefs = sorted(briefs_dir.glob("S*_executive_brief.md"))
    filled = [b for b in briefs if b.stat().st_size > 200]
    if filled:
        print(f"  PASS  {len(filled)} executive brief(s) with content")
        results["pass"] += 1
    else:
        print(f"  INFO  no executive briefs filled in yet")
        results["info"] += 1
    return True


def main():
    print("=" * 60)
    print("GIS805 -- NexaMart Autograding")
    print("=" * 60)

    print("\n[1/4] Required files")
    check_files()

    print("\n[2/4] Raw CSV data")
    csv_count = check_raw_csvs()

    print("\n[3/4] Database checks")
    db_ok = check_database()

    print("\n[4/4] Executive briefs")
    check_briefs()

    print("\n" + "=" * 60)
    print(f"PASS: {results['pass']}  |  FAIL: {results['fail']}  |  INFO: {results['info']}  |  SKIP: {results['skip']}")
    print("=" * 60)

    if results["fail"] > 0:
        print(f"\nRESULT: {results['fail']} check(s) FAILED")
        sys.exit(1)
    else:
        print("\nRESULT: All checks passed")
        sys.exit(0)


if __name__ == "__main__":
    main()
