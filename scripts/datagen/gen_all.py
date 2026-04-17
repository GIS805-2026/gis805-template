"""
GIS805 -- gen_all.py  Master runner for NexaMart data generators.

Runs the shared seed generator + all session generators for a given
--team-seed and writes output to data/synthetic/team_<seed>/<session>/.

Usage
-----
  # generate everything for team 7
  python scripts/datagen/gen_all.py --team-seed 7

  # generate only sessions 2 and 6
  python scripts/datagen/gen_all.py --team-seed 7 --sessions 2 6
"""
from __future__ import annotations

import argparse
import subprocess
import sys
import time
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent

GENERATORS = {
    0: ("Shared Seeds",            "gen_shared_seeds.py"),
    2: ("S02 -- Star Schema",      "gen_s02_star_schema.py"),
    3: ("S03 -- SCD Changes",      "gen_s03_scd_changes.py"),
    4: ("S04 -- Basket & Flags",   "gen_s04_basket_flags.py"),
    6: ("S06 -- Enterprise Integration", "gen_s06_enterprise_integration.py"),
    7: ("S07 -- Special Dims",     "gen_s07_special_dims.py"),
    8: ("S08 -- Bridges & SCD3",   "gen_s08_bridges.py"),
    9: ("S09 -- Four Fact Types",  "gen_s09_fact_types.py"),
}


def main():
    parser = argparse.ArgumentParser(description="Run all NexaMart data generators")
    parser.add_argument("--team-seed", type=int, required=True, help="Team number (1-30).")
    parser.add_argument("--sessions", type=int, nargs="*", default=None,
                        help="Only generate specific sessions (e.g. 2 6 9). 0=shared seeds.")
    args = parser.parse_args()

    sessions = args.sessions if args.sessions is not None else sorted(GENERATORS.keys())
    # Always run shared seeds first if generating all
    if args.sessions is None and 0 not in sessions:
        sessions = [0] + sessions

    t0 = time.perf_counter()
    failed = []
    for s in sessions:
        if s not in GENERATORS:
            print(f"  [SKIP] No generator for session {s}")
            continue
        label, script = GENERATORS[s]
        print(f"\n  > {label} ...")
        result = subprocess.run(
            [sys.executable, str(SCRIPT_DIR / script), "--team-seed", str(args.team_seed)],
            cwd=str(SCRIPT_DIR.parent.parent),
        )
        if result.returncode != 0:
            failed.append(label)
            print(f"  X {label} failed (exit {result.returncode})")

    elapsed = time.perf_counter() - t0
    print(f"\n{'='*60}")
    print(f"  Done in {elapsed:.1f}s -- {len(sessions) - len(failed)}/{len(sessions)} OK")
    if failed:
        print(f"  FAILED: {', '.join(failed)}")
    print(f"{'='*60}\n")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
