"""Smoke-test FK integrity across every raw_fact table in the NexaMart db.

Run after `gen_all.py` + `run_pipeline.py` for a given team-seed.
Exits 0 when all FK checks return 0 orphans.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[2]
DB = ROOT / "db" / "nexamart.duckdb"
META = ROOT / "meta" / "dataset_identity.json"

CHECKS = [
    ("fact_sales.customer_id", "raw_fact_sales", "raw_dim_customer", "customer_id"),
    ("fact_sales.product_id",  "raw_fact_sales", "raw_dim_product",  "product_id"),
    ("orders_tx.customer_id",  "raw_fact_orders_transaction", "raw_dim_customer", "customer_id"),
    ("orders_tx.product_id",   "raw_fact_orders_transaction", "raw_dim_product",  "product_id"),
    ("pipeline.product_id",    "raw_fact_order_pipeline", "raw_dim_product",  "product_id"),
    ("pipeline.customer_id",   "raw_fact_order_pipeline", "raw_dim_customer", "customer_id"),
    ("bridge.customer_id",     "raw_bridge_customer_segment", "raw_dim_customer", "customer_id"),
    ("returns.product_id",     "raw_fact_returns", "raw_dim_product",  "product_id"),
    ("s04_orders.customer_id", "raw_orders", "raw_dim_customer", "customer_id"),
    ("s04_lines.product_id",   "raw_order_lines", "raw_dim_product", "product_id"),
    ("daily_inv.product_id",   "raw_fact_daily_inventory", "raw_dim_product", "product_id"),
    ("promo.customer_id",      "raw_fact_promo_exposure", "raw_dim_customer", "customer_id"),
]


def main() -> int:
    con = duckdb.connect(str(DB), read_only=True)
    total = 0
    for name, fact, dim, key in CHECKS:
        n = con.execute(
            f"SELECT COUNT(*) FROM {fact} f "
            f"LEFT JOIN {dim} d USING({key}) WHERE d.{key} IS NULL"
        ).fetchone()[0]
        total += n
        if n:
            print(f"  X {name}: {n} orphans")
    print(f"  TOTAL ORPHANS: {total}")
    ident = json.loads(META.read_text(encoding="utf-8"))
    print(
        f"  identity fp={ident['fingerprint']} "
        f"n_prod={ident['n_products']} n_cust={ident['n_customers']}"
    )
    return 0 if total == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
