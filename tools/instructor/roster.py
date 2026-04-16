#!/usr/bin/env python3
"""
Instructor Roster Manager for GIS805

Manages the mapping between students, tokens, and expected dataset fingerprints.
The roster file is PRIVATE and should never be committed to student repos.

Usage:
    python roster.py init                          # Create empty roster
    python roster.py add "Jean Tremblay" jtre1234  # Add student
    python roster.py list                          # Show all students
    python roster.py verify jtre1234               # Verify a token's expected hash
"""

import csv
import hashlib
import json
import os
import sys
from pathlib import Path

ROSTER_FILE = Path(__file__).parent / "roster.csv"
ROSTER_FIELDS = [
    "student_name",
    "student_id",
    "github_username",
    "token",
    "scenario_family",
    "expected_seed_hash",
]


def get_salt() -> str:
    salt = os.environ.get("GIS805_SALT", "")
    if not salt:
        print("WARNING: GIS805_SALT not set. Hashes will use empty salt.")
    return salt


def compute_seed_hash(token: str, scenario_family: str = "baseline") -> str:
    salt = get_salt()
    combined = f"{salt}:{token}:{scenario_family}"
    return hashlib.sha256(combined.encode()).hexdigest()[:16]


def cmd_init():
    if ROSTER_FILE.exists():
        print(f"Roster already exists: {ROSTER_FILE}")
        return
    with open(ROSTER_FILE, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=ROSTER_FIELDS)
        writer.writeheader()
    print(f"Created empty roster: {ROSTER_FILE}")


def cmd_add(name: str, github_username: str, student_id: str = "", token: str = "", scenario: str = "baseline"):
    if not token:
        token = hashlib.sha256(f"{name}:{github_username}".encode()).hexdigest()[:8]
        print(f"Generated token: {token}")

    seed_hash = compute_seed_hash(token, scenario)

    row = {
        "student_name": name,
        "student_id": student_id,
        "github_username": github_username,
        "token": token,
        "scenario_family": scenario,
        "expected_seed_hash": seed_hash,
    }

    if not ROSTER_FILE.exists():
        cmd_init()

    with open(ROSTER_FILE, "a", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=ROSTER_FIELDS)
        writer.writerow(row)

    print(f"Added: {name} ({github_username}) -> token={token}, hash={seed_hash}")


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

    print(f"{'Name':<25} {'GitHub':<20} {'Token':<12} {'Hash':<18} {'Scenario'}")
    print("-" * 90)
    for r in rows:
        print(
            f"{r['student_name']:<25} {r['github_username']:<20} "
            f"{r['token']:<12} {r['expected_seed_hash']:<18} {r['scenario_family']}"
        )
    print(f"\nTotal: {len(rows)} students")


def cmd_verify(token: str, scenario: str = "baseline"):
    seed_hash = compute_seed_hash(token, scenario)
    print(f"Token:    {token}")
    print(f"Scenario: {scenario}")
    print(f"Hash:     {seed_hash}")

    if ROSTER_FILE.exists():
        with open(ROSTER_FILE, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for r in reader:
                if r["token"] == token:
                    match = r["expected_seed_hash"] == seed_hash
                    print(f"Student:  {r['student_name']} ({r['github_username']})")
                    print(f"Match:    {'YES' if match else 'NO -- expected ' + r['expected_seed_hash']}")
                    return
        print("Token not found in roster.")


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
            print("Usage: roster.py add <name> <github_username> [student_id] [token] [scenario]")
            sys.exit(1)
        name = sys.argv[2]
        github = sys.argv[3]
        sid = sys.argv[4] if len(sys.argv) > 4 else ""
        tok = sys.argv[5] if len(sys.argv) > 5 else ""
        scn = sys.argv[6] if len(sys.argv) > 6 else "baseline"
        cmd_add(name, github, sid, tok, scn)
    elif cmd == "list":
        cmd_list()
    elif cmd == "verify":
        if len(sys.argv) < 3:
            print("Usage: roster.py verify <token> [scenario]")
            sys.exit(1)
        tok = sys.argv[2]
        scn = sys.argv[3] if len(sys.argv) > 3 else "baseline"
        cmd_verify(tok, scn)
    elif cmd == "export":
        cmd_export_json()
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)
