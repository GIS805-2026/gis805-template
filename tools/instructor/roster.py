#!/usr/bin/env python3
"""
Instructor Roster Manager for GIS805

Manages the mapping between students and their expected dataset fingerprints.
Seeds are derived from git usernames via MD5 -- no salt or token distribution needed.
The roster file is PRIVATE and should never be committed to student repos.

Usage:
    python roster.py init                                    # Create empty roster
    python roster.py add "Jean Tremblay" jtre1234 12345678   # Add student
    python roster.py list                                    # Show all students
    python roster.py verify jtre1234                         # Verify expected seed
    python roster.py export                                  # Export to JSON
"""

import csv
import hashlib
import json
import sys
from pathlib import Path

ROSTER_FILE = Path(__file__).parent / "roster.csv"
ROSTER_FIELDS = [
    "student_name",
    "student_id",
    "github_username",
    "seed",
    "scenario_family",
]


def compute_seed(github_username: str) -> str:
    """Derive deterministic seed from git username (matches datagen logic)."""
    return hashlib.md5(github_username.encode()).hexdigest()[:8]


def cmd_init():
    if ROSTER_FILE.exists():
        print(f"Roster already exists: {ROSTER_FILE}")
        return
    with open(ROSTER_FILE, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=ROSTER_FIELDS)
        writer.writeheader()
    print(f"Created empty roster: {ROSTER_FILE}")


def cmd_add(name: str, github_username: str, student_id: str = ""):
    seed = compute_seed(github_username)

    row = {
        "student_name": name,
        "student_id": student_id,
        "github_username": github_username,
        "seed": seed,
        "scenario_family": "NEXAMART_RETAIL_2026",
    }

    if not ROSTER_FILE.exists():
        cmd_init()

    with open(ROSTER_FILE, "a", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=ROSTER_FIELDS)
        writer.writerow(row)

    print(f"Added: {name} ({github_username}) -> seed={seed}")


def cmd_list():
    if not ROSTER_FILE.exists():
        print("No roster file found. Run 'roster.py init' first.")
        return

    with open(ROSTER_FILE, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = list(reader)

    if not rows:
        print("Roster is empty.")
        return

    print(f"{'Name':<25} {'GitHub':<20} {'Seed':<12} {'Student ID'}")
    print("-" * 70)
    for r in rows:
        print(
            f"{r['student_name']:<25} {r['github_username']:<20} "
            f"{r['seed']:<12} {r.get('student_id', '')}"
        )
    print(f"\nTotal: {len(rows)} students")


def cmd_verify(github_username: str):
    seed = compute_seed(github_username)
    print(f"Username: {github_username}")
    print(f"Seed:     {seed}")

    if ROSTER_FILE.exists():
        with open(ROSTER_FILE, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for r in reader:
                if r["github_username"] == github_username:
                    match = r["seed"] == seed
                    print(f"Student:  {r['student_name']}")
                    print(f"Match:    {'YES' if match else 'NO -- expected ' + r['seed']}")
                    return
        print("Username not found in roster.")


def cmd_export_json():
    if not ROSTER_FILE.exists():
        print("No roster file found.")
        return

    with open(ROSTER_FILE, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = list(reader)

    output = ROSTER_FILE.with_suffix(".json")
    with open(output, "w", encoding="utf-8") as f:
        json.dump(rows, f, indent=2, ensure_ascii=False)
    print(f"Exported {len(rows)} entries to {output}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: roster.py <init|add|list|verify|export>")
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "init":
        cmd_init()
    elif cmd == "add":
        if len(sys.argv) < 4:
            print("Usage: roster.py add <name> <github_username> [student_id]")
            sys.exit(1)
        name = sys.argv[2]
        github = sys.argv[3]
        sid = sys.argv[4] if len(sys.argv) > 4 else ""
        cmd_add(name, github, sid)
    elif cmd == "list":
        cmd_list()
    elif cmd == "verify":
        if len(sys.argv) < 3:
            print("Usage: roster.py verify <github_username>")
            sys.exit(1)
        cmd_verify(sys.argv[2])
    elif cmd == "export":
        cmd_export_json()
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)
