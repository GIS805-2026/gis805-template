#!/usr/bin/env python3
"""Compute a deterministic integer team seed from the git username.

Used by Makefile (Unix/Codespace) and run.ps1 (Windows) so the seed
calculation is identical across platforms.

Prints the seed as a single integer to stdout, or "1" if git is unavailable.
"""
from __future__ import annotations

import hashlib
import subprocess
import sys


def compute_seed(username: str) -> int:
    digest = hashlib.md5(username.encode("utf-8")).hexdigest()[:8]
    return int(digest, 16)


def main() -> int:
    try:
        out = subprocess.run(
            ["git", "config", "user.name"],
            check=True, capture_output=True, text=True, timeout=5,
        ).stdout.strip()
    except Exception:
        out = ""
    if not out:
        print("1")
        return 0
    print(compute_seed(out))
    return 0


if __name__ == "__main__":
    sys.exit(main())
