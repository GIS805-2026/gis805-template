#!/usr/bin/env python3
"""
Batch Validate -- Run validation checks against all student DuckDB databases.

Usage:
    python batch_validate.py --repos ./student-repos --output grading_summary.csv

Requires: duckdb Python package (pip install duckdb)
"""

import argparse
import csv
import sys
from pathlib import Path

try:
    import duckdb
except ImportError:
    print("duckdb package required: pip install duckdb")
    sys.exit(1)


QUICK_CHECKS = [
    ("db_exists", "Database file exists"),
    ("tables_exist", "Required tables present"),
    ("row_counts", "Row counts above minimum"),
    ("key_integrity", "No orphan foreign keys"),
    ("identity_exists", "Dataset identity file present"),
    ("ai_usage_exists", "AI usage trace file present"),
    ("brief_exists", "Executive brief exists for latest session"),
]


def check_file_exists(repo_path: Path, relative: str) -> bool:
    return (repo_path / relative).exists()


def check_db(repo_path: Path) -> dict:
    """Run validation checks on a student's DuckDB."""
    result = {
        "repo": repo_path.name,
        "db_exists": False,
        "tables_exist": False,
        "row_counts": False,
        "key_integrity": False,
        "identity_exists": False,
        "ai_usage_exists": False,
        "brief_exists": False,
        "total_fact_rows": 0,
        "total_dim_rows": 0,
        "errors": "",
    }

    db_path = repo_path / "db" / "nexamart.duckdb"
    if not db_path.exists():
        result["errors"] = "Database file not found"
        return result
    result["db_exists"] = True

    result["identity_exists"] = check_file_exists(repo_path, "meta/dataset_identity.json")
    result["ai_usage_exists"] = check_file_exists(repo_path, "ai-usage.md")

    briefs = sorted((repo_path / "answers").glob("S*_executive_brief.md")) if (repo_path / "answers").exists() else []
    result["brief_exists"] = len(briefs) > 0

    try:
        con = duckdb.connect(str(db_path), read_only=True)

        tables = [r[0] for r in con.execute("SHOW TABLES").fetchall()]
        required = {"raw_customers", "raw_products", "raw_stores", "raw_orders"}
        result["tables_exist"] = required.issubset(set(tables))

        fact_tables = [t for t in tables if t.startswith("fact_")]
        dim_tables = [t for t in tables if t.startswith("dim_")]

        total_fact = 0
        for t in fact_tables:
            cnt = con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
            total_fact += cnt
        result["total_fact_rows"] = total_fact

        total_dim = 0
        for t in dim_tables:
            cnt = con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
            total_dim += cnt
        result["total_dim_rows"] = total_dim

        result["row_counts"] = total_fact > 0 and total_dim > 0

        orphans = 0
        if "fact_sales" in tables and "dim_customer" in tables:
            try:
                orphan_count = con.execute("""
                    SELECT COUNT(*) FROM fact_sales f
                    LEFT JOIN dim_customer d ON f.customer_key = d.customer_key
                    WHERE d.customer_key IS NULL
                """).fetchone()[0]
                orphans += orphan_count
            except Exception:
                pass
        result["key_integrity"] = orphans == 0

        con.close()

    except Exception as exc:
        result["errors"] = str(exc)

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

    student_repos = sorted([d for d in repos_dir.iterdir() if d.is_dir() and (d / "db").exists() or (d / "src").exists()])
    print(f"Found {len(student_repos)} student repos.\n")

    results = []
    for repo_path in student_repos:
        print(f"Checking {repo_path.name}...", end=" ")
        r = check_db(repo_path)
        passed = sum(1 for c, _ in QUICK_CHECKS if r.get(c, False))
        print(f"{passed}/{len(QUICK_CHECKS)} checks passed")
        results.append(r)

    fieldnames = ["repo", "db_exists", "tables_exist", "row_counts", "key_integrity",
                   "identity_exists", "ai_usage_exists", "brief_exists",
                   "total_fact_rows", "total_dim_rows", "errors"]

    output_path = Path(args.output)
    with open(output_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for r in results:
            writer.writerow(r)

    print(f"\nSummary written to {output_path.resolve()}")

    total = len(results)
    all_pass = sum(1 for r in results if all(r.get(c, False) for c, _ in QUICK_CHECKS))
    print(f"Full pass: {all_pass}/{total} students")


if __name__ == "__main__":
    main()
