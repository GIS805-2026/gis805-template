#!/usr/bin/env python3
"""
Batch Validate -- Run validation checks against all student DuckDB databases.

Wraps src/run_checks.py (the canonical validator) across every student repo
under --repos, plus a few file-existence checks, and emits grading_summary.csv.

Usage:
    python batch_validate.py --repos ./student-repos --output grading_summary.csv

Requires: duckdb Python package (pip install duckdb)
"""

import argparse
import csv
import json
import subprocess
import sys
from pathlib import Path

try:
    import duckdb
except ImportError:
    print("duckdb package required: pip install duckdb")
    sys.exit(1)


# Raw tables produced by run_pipeline.py (stem of each generated CSV,
# prefixed with raw_). Shared seeds are always present after `make generate`.
REQUIRED_RAW_TABLES = {
    "raw_dim_customer",
    "raw_dim_product",
    "raw_dim_store",
    "raw_dim_channel",
    "raw_dim_date",
    "raw_fact_sales",
}


def check_file_exists(repo_path: Path, relative: str) -> bool:
    return (repo_path / relative).exists()


def check_db(repo_path: Path) -> dict:
    """Run validation checks on a student's DuckDB."""
    result = {
        "repo": repo_path.name,
        "db_exists": False,
        "raw_tables_complete": False,
        "dim_tables_built": 0,
        "fact_tables_built": 0,
        "fact_sales_rows": 0,
        "fk_orphans_fact_sales": -1,
        "identity_present": False,
        "identity_fingerprint_ok": False,
        "ai_usage_present": False,
        "brief_present": False,
        "run_checks_exit": -1,
        "errors": "",
    }

    db_path = repo_path / "db" / "nexamart.duckdb"
    if not db_path.exists():
        result["errors"] = "Database file not found"
        return result
    result["db_exists"] = True

    # File-level artefacts
    identity_path = repo_path / "meta" / "dataset_identity.json"
    result["identity_present"] = identity_path.exists()
    if result["identity_present"]:
        try:
            data = json.loads(identity_path.read_text(encoding="utf-8"))
            result["identity_fingerprint_ok"] = bool(data.get("fingerprint")) and data.get("fingerprint") != "null"
        except Exception:
            result["identity_fingerprint_ok"] = False

    result["ai_usage_present"] = check_file_exists(repo_path, "ai-usage.md")

    briefs = (
        sorted((repo_path / "answers").glob("S*_executive_brief.md"))
        if (repo_path / "answers").exists() else []
    )
    result["brief_present"] = any(b.stat().st_size > 200 for b in briefs)

    # Database-level checks
    try:
        con = duckdb.connect(str(db_path), read_only=True)
        tables = {r[0] for r in con.execute("SHOW TABLES").fetchall()}
        result["raw_tables_complete"] = REQUIRED_RAW_TABLES.issubset(tables)
        result["dim_tables_built"] = sum(1 for t in tables if t.startswith("dim_"))
        result["fact_tables_built"] = sum(1 for t in tables if t.startswith("fact_"))

        if "fact_sales" in tables:
            result["fact_sales_rows"] = con.execute(
                "SELECT COUNT(*) FROM fact_sales"
            ).fetchone()[0]
            if "dim_customer" in tables:
                result["fk_orphans_fact_sales"] = con.execute("""
                    SELECT COUNT(*) FROM fact_sales f
                    LEFT JOIN dim_customer d ON f.customer_id = d.customer_id
                    WHERE d.customer_id IS NULL
                """).fetchone()[0]
        elif "raw_fact_sales" in tables:
            result["fact_sales_rows"] = con.execute(
                "SELECT COUNT(*) FROM raw_fact_sales"
            ).fetchone()[0]

        con.close()
    except Exception as exc:
        result["errors"] = str(exc)

    # Invoke the canonical checker (skips unbuilt tables gracefully)
    runner = repo_path / "src" / "run_checks.py"
    if runner.exists():
        proc = subprocess.run(
            [sys.executable, str(runner)],
            cwd=str(repo_path), capture_output=True, text=True, timeout=120,
        )
        result["run_checks_exit"] = proc.returncode

    return result


def main():
    parser = argparse.ArgumentParser(description="Batch validate student DuckDB databases")
    parser.add_argument("--repos", default="./student-repos", help="Directory containing student repos")
    parser.add_argument("--output", default="grading_summary.csv", help="Output CSV file")
    args = parser.parse_args()

    repos_dir = Path(args.repos)
    if not repos_dir.exists():
        print(f"Repos directory not found: {repos_dir}")
        sys.exit(1)

    student_repos = sorted(
        d for d in repos_dir.iterdir()
        if d.is_dir() and ((d / "db").exists() or (d / "src").exists())
    )
    print(f"Found {len(student_repos)} student repos.\n")

    results = []
    for repo_path in student_repos:
        print(f"Checking {repo_path.name}...", end=" ", flush=True)
        r = check_db(repo_path)
        flag = "OK" if r["run_checks_exit"] == 0 and not r["errors"] else "FAIL"
        print(f"{flag}  db={r['db_exists']} raw={r['raw_tables_complete']} "
              f"dims={r['dim_tables_built']} facts={r['fact_tables_built']} "
              f"orphans={r['fk_orphans_fact_sales']}")
        results.append(r)

    fieldnames = list(results[0].keys()) if results else [
        "repo","db_exists","raw_tables_complete","dim_tables_built","fact_tables_built",
        "fact_sales_rows","fk_orphans_fact_sales","identity_present",
        "identity_fingerprint_ok","ai_usage_present","brief_present",
        "run_checks_exit","errors",
    ]

    output_path = Path(args.output)
    with open(output_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)

    print(f"\nSummary written to {output_path.resolve()}")
    total = len(results)
    clean = sum(1 for r in results
                if r["db_exists"] and r["raw_tables_complete"] and r["run_checks_exit"] == 0)
    print(f"Clean repos: {clean}/{total}")


if __name__ == "__main__":
    main()
