#!/usr/bin/env python3
"""
NexaMart Synthetic Data Generator for GIS805

Generates unique, comparable datasets for each student based on their token.
Each dataset has the same schema but different distributions, enabling
fair evaluation while reducing copying.

Usage:
    python generate_data.py --token YOUR_TOKEN [--scale 1.0] [--output data/raw]
"""

import hashlib
import json
import os
import random
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any

import click
from faker import Faker

# Configuration
DEFAULT_SCALE = 1.0
DEFAULT_OUTPUT = "data/raw"
SCENARIO_FAMILIES = ["baseline", "seasonal", "regional", "promotional"]


def generate_seed(token: str, scenario_family: str = "baseline") -> int:
    """Generate deterministic seed from token, scenario family, and optional salt.

    The instructor can set GIS805_SALT as an environment variable to add a
    secret component.  Students leave it unset (empty string) -- the data
    still generates correctly; the salt only matters for the instructor's
    ability to verify dataset provenance.
    """
    salt = os.environ.get("GIS805_SALT", "")
    combined = f"{salt}:{token}:{scenario_family}"
    hash_bytes = hashlib.sha256(combined.encode()).digest()
    return int.from_bytes(hash_bytes[:4], "big")


def create_faker_with_seed(seed: int) -> Faker:
    """Create seeded Faker instance for reproducible generation."""
    Faker.seed(seed)
    fake = Faker("fr_CA")
    return fake


class NexaMartGenerator:
    """Generates NexaMart synthetic data with deterministic randomness."""

    def __init__(self, seed: int, scale: float = 1.0):
        self.seed = seed
        self.scale = scale
        self.rng = random.Random(seed)
        self.fake = create_faker_with_seed(seed)
        
        # Derived parameters based on seed (creates unique distributions)
        self.seasonality_strength = 0.1 + (self.rng.random() * 0.4)
        self.return_rate = 0.02 + (self.rng.random() * 0.08)
        self.regional_skew = self.rng.choice(["east", "west", "balanced"])
        self.promo_effectiveness = 0.8 + (self.rng.random() * 0.4)

    def _generate_customers(self, n: int) -> list[dict[str, Any]]:
        """Generate customer records."""
        customers = []
        segments = ["Premium", "Standard", "Budget", "New"]
        segment_weights = [0.15, 0.45, 0.30, 0.10]
        
        for i in range(1, n + 1):
            customer = {
                "customer_id": f"CUST{i:06d}",
                "customer_name": self.fake.name(),
                "email": self.fake.email(),
                "segment": self.rng.choices(segments, segment_weights)[0],
                "city": self.fake.city(),
                "province": self.rng.choice(["QC", "ON", "BC", "AB"]),
                "registration_date": self.fake.date_between(
                    start_date="-5y", end_date="-30d"
                ).isoformat(),
                "is_active": self.rng.random() > 0.1,
            }
            customers.append(customer)
        return customers

    def _generate_products(self, n: int) -> list[dict[str, Any]]:
        """Generate product catalog."""
        categories = [
            ("Electronics", ["Phones", "Laptops", "Accessories", "Audio"]),
            ("Home", ["Furniture", "Decor", "Kitchen", "Garden"]),
            ("Clothing", ["Men", "Women", "Kids", "Sports"]),
            ("Food", ["Fresh", "Frozen", "Beverages", "Snacks"]),
        ]
        
        products = []
        for i in range(1, n + 1):
            category, subcats = self.rng.choice(categories)
            subcategory = self.rng.choice(subcats)
            base_price = self.rng.uniform(5, 500)
            
            product = {
                "product_id": f"PROD{i:05d}",
                "product_name": f"{self.fake.word().title()} {subcategory} Item",
                "category": category,
                "subcategory": subcategory,
                "unit_price": round(base_price, 2),
                "unit_cost": round(base_price * self.rng.uniform(0.4, 0.7), 2),
                "brand": self.fake.company().split()[0],
                "supplier_id": f"SUP{self.rng.randint(1, 20):03d}",
                "is_active": self.rng.random() > 0.05,
            }
            products.append(product)
        return products

    def _generate_stores(self, n: int) -> list[dict[str, Any]]:
        """Generate store locations."""
        regions = {
            "east": ["QC", "ON", "NB", "NS"],
            "west": ["BC", "AB", "SK", "MB"],
            "balanced": ["QC", "ON", "BC", "AB"],
        }
        provinces = regions[self.regional_skew]
        
        stores = []
        for i in range(1, n + 1):
            store = {
                "store_id": f"STORE{i:03d}",
                "store_name": f"NexaMart {self.fake.city()}",
                "province": self.rng.choice(provinces),
                "city": self.fake.city(),
                "store_type": self.rng.choice(["Flagship", "Standard", "Express"]),
                "sqft": self.rng.randint(5000, 50000),
                "opening_date": self.fake.date_between(
                    start_date="-10y", end_date="-1y"
                ).isoformat(),
            }
            stores.append(store)
        return stores

    def _generate_orders(
        self, n: int, customers: list, stores: list, products: list
    ) -> tuple[list[dict], list[dict]]:
        """Generate orders and order lines."""
        orders = []
        order_lines = []
        
        # Generate order ID range based on seed (fingerprinting)
        order_id_start = 100000 + (self.seed % 900000)
        
        for i in range(n):
            order_id = f"ORD{order_id_start + i:07d}"
            customer = self.rng.choice(customers)
            store = self.rng.choice(stores)
            
            # Date with seasonality
            base_date = self.fake.date_between(start_date="-2y", end_date="today")
            
            order = {
                "order_id": order_id,
                "customer_id": customer["customer_id"],
                "store_id": store["store_id"],
                "order_date": base_date.isoformat(),
                "order_status": self.rng.choices(
                    ["completed", "returned", "cancelled"],
                    [0.90 - self.return_rate, self.return_rate, 0.02],
                )[0],
            }
            orders.append(order)
            
            # Generate 1-5 line items per order
            num_items = self.rng.randint(1, 5)
            selected_products = self.rng.sample(
                products, min(num_items, len(products))
            )
            
            for line_num, product in enumerate(selected_products, 1):
                quantity = self.rng.randint(1, 3)
                unit_price = product["unit_price"]
                discount_pct = self.rng.choice([0, 0, 0, 0.05, 0.10, 0.15])
                
                line = {
                    "order_id": order_id,
                    "line_number": line_num,
                    "product_id": product["product_id"],
                    "quantity": quantity,
                    "unit_price": unit_price,
                    "discount_pct": discount_pct,
                    "line_total": round(quantity * unit_price * (1 - discount_pct), 2),
                }
                order_lines.append(line)
        
        return orders, order_lines

    def _generate_returns(
        self, orders: list, order_lines: list
    ) -> list[dict[str, Any]]:
        """Generate return records for returned orders."""
        returns = []
        returned_orders = [o for o in orders if o["order_status"] == "returned"]
        
        for order in returned_orders:
            lines = [l for l in order_lines if l["order_id"] == order["order_id"]]
            if not lines:
                continue
                
            # Return some or all items
            returned_lines = self.rng.sample(
                lines, self.rng.randint(1, len(lines))
            )
            
            for line in returned_lines:
                return_record = {
                    "return_id": f"RET{self.rng.randint(100000, 999999)}",
                    "order_id": order["order_id"],
                    "product_id": line["product_id"],
                    "quantity_returned": line["quantity"],
                    "return_date": (
                        datetime.fromisoformat(order["order_date"])
                        + timedelta(days=self.rng.randint(1, 30))
                    ).date().isoformat(),
                    "reason": self.rng.choice([
                        "defective", "wrong_item", "changed_mind", "not_as_described"
                    ]),
                    "refund_amount": line["line_total"],
                }
                returns.append(return_record)
        
        return returns

    def _generate_budgets(self, stores: list) -> list[dict[str, Any]]:
        """Generate budget targets by store and month."""
        budgets = []
        
        for store in stores:
            for year in [2024, 2025, 2026]:
                for month in range(1, 13):
                    if year == 2026 and month > 4:
                        continue
                    
                    base_budget = self.rng.uniform(50000, 200000)
                    # Seasonal variation
                    seasonal_factor = 1.0 + self.seasonality_strength * (
                        0.3 if month in [11, 12] else -0.1 if month in [1, 2] else 0
                    )
                    
                    budget = {
                        "store_id": store["store_id"],
                        "year": year,
                        "month": month,
                        "revenue_budget": round(base_budget * seasonal_factor, 2),
                        "transaction_budget": int(base_budget / 50),
                    }
                    budgets.append(budget)
        
        return budgets

    def _generate_campaigns(self, products: list) -> list[dict[str, Any]]:
        """Generate marketing campaign exposure data."""
        campaigns = []
        campaign_types = ["email", "social", "tv", "flyer", "in_store"]
        
        for i in range(1, 51):  # 50 campaigns
            start_date = self.fake.date_between(start_date="-2y", end_date="-30d")
            
            campaign = {
                "campaign_id": f"CAMP{i:03d}",
                "campaign_name": f"{self.fake.word().title()} {self.rng.choice(['Sale', 'Promo', 'Event'])}",
                "campaign_type": self.rng.choice(campaign_types),
                "start_date": start_date.isoformat(),
                "end_date": (start_date + timedelta(days=self.rng.randint(7, 30))).isoformat(),
                "budget_spent": round(self.rng.uniform(1000, 50000), 2),
                "target_category": self.rng.choice(["Electronics", "Home", "Clothing", "Food", "All"]),
            }
            campaigns.append(campaign)
        
        return campaigns

    def generate_all(self) -> dict[str, list]:
        """Generate complete dataset."""
        # Scale factors
        n_customers = int(500 * self.scale)
        n_products = int(200 * self.scale)
        n_stores = int(15 * self.scale)
        n_orders = int(5000 * self.scale)
        
        print(f"Generating {n_customers} customers...")
        customers = self._generate_customers(n_customers)
        
        print(f"Generating {n_products} products...")
        products = self._generate_products(n_products)
        
        print(f"Generating {n_stores} stores...")
        stores = self._generate_stores(n_stores)
        
        print(f"Generating {n_orders} orders with line items...")
        orders, order_lines = self._generate_orders(n_orders, customers, stores, products)
        
        print("Generating returns...")
        returns = self._generate_returns(orders, order_lines)
        
        print("Generating budgets...")
        budgets = self._generate_budgets(stores)
        
        print("Generating campaigns...")
        campaigns = self._generate_campaigns(products)
        
        return {
            "customers": customers,
            "products": products,
            "stores": stores,
            "orders": orders,
            "order_lines": order_lines,
            "returns": returns,
            "budgets": budgets,
            "campaigns": campaigns,
        }


def save_csv(data: list[dict], filepath: Path) -> None:
    """Save data to CSV file."""
    if not data:
        return
    
    import csv
    
    filepath.parent.mkdir(parents=True, exist_ok=True)
    
    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=data[0].keys())
        writer.writeheader()
        writer.writerows(data)
    
    print(f"  Saved {len(data)} rows to {filepath}")


def save_metadata(token: str, seed: int, scale: float, output_dir: Path) -> None:
    """Save dataset identity metadata."""
    metadata = {
        "dataset_version": "1.0",
        "generated_at": datetime.now().isoformat(),
        "token_hash": hashlib.sha256(token.encode()).hexdigest()[:16],
        "seed_hash": hashlib.sha256(str(seed).encode()).hexdigest()[:16],
        "scale_factor": scale,
        "scenario_family": "baseline",
        "generator_version": "gis805-v1",
    }
    
    metadata_dir = output_dir.parent / "metadata"
    metadata_dir.mkdir(parents=True, exist_ok=True)
    
    with open(metadata_dir / "dataset_identity.json", "w") as f:
        json.dump(metadata, f, indent=2)
    
    print(f"  Saved metadata to {metadata_dir / 'dataset_identity.json'}")


@click.command()
@click.option("--token", required=True, help="Your unique student token")
@click.option("--scale", default=DEFAULT_SCALE, help="Scale factor for data volume")
@click.option("--output", default=DEFAULT_OUTPUT, help="Output directory for CSV files")
def main(token: str, scale: float, output: str):
    """Generate NexaMart synthetic data for GIS805."""
    print(f"\n{'='*60}")
    print("NexaMart Data Generator for GIS805")
    print(f"{'='*60}\n")
    
    # Generate seed from token
    seed = generate_seed(token)
    print(f"Token: {token}")
    print(f"Seed: {seed}")
    print(f"Scale: {scale}")
    print()
    
    # Initialize generator
    generator = NexaMartGenerator(seed=seed, scale=scale)
    
    # Generate all data
    print("Generating data...")
    data = generator.generate_all()
    
    # Save to CSV files
    output_path = Path(output)
    print(f"\nSaving to {output_path}/...")
    
    for name, records in data.items():
        save_csv(records, output_path / f"{name}.csv")
    
    # Save metadata
    save_metadata(token, seed, scale, output_path)
    
    print(f"\n{'='*60}")
    print("Generation complete!")
    print(f"{'='*60}\n")
    print("Next steps:")
    print("1. Load data into DuckDB: python src/run_pipeline.py")
    print("2. Explore with: duckdb db/nexamart.duckdb")
    print()


if __name__ == "__main__":
    main()
