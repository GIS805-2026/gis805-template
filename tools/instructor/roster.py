#!/usr/bin/env python3
"""Instructor roster verification tool for GIS805 NexaMart.

Given a student's GitHub username, computes the deterministic seed and
dataset fingerprint so the instructor can verify the student's repository
contains data generated with the correct seed.

Usage
-----
    python roster.py <github-username>
    python roster.py alice-tremblay

Both compute_seed() and compute_fingerprint() must stay byte-for-byte
consistent with _compute_seed.py (used by Makefile/run.ps1) and
_helpers.fingerprint() (used by gen_shared_seeds.py).
"""
from __future__ import annotations

import hashlib
import sys

SCENARIO_FAMILY = "NEXAMART_RETAIL_2026"


def compute_seed(username: str) -> int:
    """Return the deterministic integer seed for a given GitHub username.

    Algorithm mirrors _compute_seed.compute_seed():
        MD5(username)[:8] interpreted as a hex integer.
    """
    digest = hashlib.md5(username.encode("utf-8")).hexdigest()[:8]
    return int(digest, 16)


def compute_fingerprint(team_seed: int) -> str:
    """Return the 16-char SHA-256 fingerprint for a given team seed.

    Algorithm mirrors _helpers.fingerprint():
        SHA-256("{SCENARIO_FAMILY}|{team_seed}")[:16]
    """
    payload = f"{SCENARIO_FAMILY}|{team_seed}".encode("utf-8")
    return hashlib.sha256(payload).hexdigest()[:16]


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <github-username>", file=sys.stderr)
        return 1
    username = sys.argv[1].strip()
    seed = compute_seed(username)
    fp = compute_fingerprint(seed)
    print(f"Username   : {username}")
    print(f"Team seed  : {seed}")
    print(f"Fingerprint: {fp}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
