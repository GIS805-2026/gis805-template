#!/usr/bin/env python3
"""
Batch Pull -- Clone or pull all student repos from the GitHub org.

Usage:
    python batch_pull.py --org GIS805-2026 --prefix gis805-2026 --dest ./student-repos

Requires: gh CLI authenticated (https://cli.github.com/)
"""

import argparse
import subprocess
import sys
from pathlib import Path


def list_repos(org: str, prefix: str) -> list[str]:
    """List repos in the org matching the prefix using gh CLI."""
    result = subprocess.run(
        ["gh", "repo", "list", org, "--json", "name", "--limit", "200"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"Error listing repos: {result.stderr}")
        sys.exit(1)

    import json
    repos = json.loads(result.stdout)
    return [r["name"] for r in repos if r["name"].startswith(prefix)]


def clone_or_pull(org: str, repo_name: str, dest: Path):
    """Clone if not exists, pull if exists."""
    repo_path = dest / repo_name
    repo_url = f"https://github.com/{org}/{repo_name}.git"

    if repo_path.exists():
        print(f"  Pulling {repo_name}...")
        result = subprocess.run(
            ["git", "-C", str(repo_path), "pull", "--ff-only"],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            print(f"  WARNING: pull failed for {repo_name}: {result.stderr.strip()}")
        else:
            print(f"  OK: {repo_name}")
    else:
        print(f"  Cloning {repo_name}...")
        result = subprocess.run(
            ["gh", "repo", "clone", f"{org}/{repo_name}", str(repo_path)],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            print(f"  WARNING: clone failed for {repo_name}: {result.stderr.strip()}")
        else:
            print(f"  OK: {repo_name}")


def main():
    parser = argparse.ArgumentParser(description="Batch clone/pull student repos")
    parser.add_argument("--org", default="GIS805-2026", help="GitHub organization")
    parser.add_argument("--prefix", default="gis805-2026", help="Repo name prefix to match")
    parser.add_argument("--dest", default="./student-repos", help="Local directory for repos")
    args = parser.parse_args()

    dest = Path(args.dest)
    dest.mkdir(parents=True, exist_ok=True)

    print(f"Listing repos in {args.org} matching '{args.prefix}*'...")
    repos = list_repos(args.org, args.prefix)
    print(f"Found {len(repos)} repos.\n")

    for repo_name in sorted(repos):
        clone_or_pull(args.org, repo_name, dest)

    print(f"\nDone. {len(repos)} repos in {dest.resolve()}")


if __name__ == "__main__":
    main()
