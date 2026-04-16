#!/usr/bin/env python3
"""
Pipeline runner for loading NexaMart data into DuckDB.

Usage:
    python run_pipeline.py [--db db/nexamart.duckdb] [--data data/raw]
"""

from pathlib import Path

import click
import duckdb


def load_raw_data(conn: duckdb.DuckDBPyConnection, data_dir: Path) -> None:
    """Load all CSV files from data/raw into DuckDB raw tables."""
    csv_files = list(data_dir.glob("*.csv"))
    
    if not csv_files:
        print(f"No CSV files found in {data_dir}")
        return
    
    print(f"Loading {len(csv_files)} CSV files...")
    
    for csv_file in csv_files:
        table_name = f"raw_{csv_file.stem}"
        print(f"  Loading {csv_file.name} -> {table_name}")
        
        conn.execute(f"""
            CREATE OR REPLACE TABLE {table_name} AS 
            SELECT * FROM read_csv_auto('{csv_file}', header=true)
        """)
        
        row_count = conn.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
        print(f"    {row_count:,} rows loaded")


def create_staging_views(conn: duckdb.DuckDBPyConnection) -> None:
    """Create staging views with basic type casting and cleaning."""
    
    # Example staging view for orders
    conn.execute("""
        CREATE OR REPLACE VIEW stg_orders AS
        SELECT
            order_id,
            customer_id,
            store_id,
            CAST(order_date AS DATE) as order_date,
            order_status
        FROM raw_orders
    """)
    
    # Example staging view for order_lines
    conn.execute("""
        CREATE OR REPLACE VIEW stg_order_lines AS
        SELECT
            order_id,
            line_number,
            product_id,
            quantity,
            unit_price,
            discount_pct,
            line_total
        FROM raw_order_lines
    """)
    
    print("Staging views created")


def run_sql_scripts(conn: duckdb.DuckDBPyConnection, sql_dir: Path) -> None:
    """Execute SQL scripts from a directory in order."""
    if not sql_dir.exists():
        return
    
    sql_files = sorted(sql_dir.glob("*.sql"))
    
    for sql_file in sql_files:
        print(f"  Executing {sql_file.name}...")
        sql = sql_file.read_text(encoding="utf-8")
        conn.execute(sql)


def show_summary(conn: duckdb.DuckDBPyConnection) -> None:
    """Display summary of loaded data."""
    print("\n" + "=" * 50)
    print("DATABASE SUMMARY")
    print("=" * 50)
    
    tables = conn.execute("""
        SELECT table_name, 
               (SELECT COUNT(*) FROM information_schema.columns c 
                WHERE c.table_name = t.table_name) as columns
        FROM information_schema.tables t
        WHERE table_schema = 'main'
        ORDER BY table_name
    """).fetchall()
    
    print(f"\nTables and views: {len(tables)}")
    print("-" * 30)
    
    for table_name, col_count in tables:
        row_count = conn.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
        print(f"  {table_name}: {row_count:,} rows, {col_count} columns")


@click.command()
@click.option("--db", default="db/nexamart.duckdb", help="Path to DuckDB database")
@click.option("--data", default="data/raw", help="Path to raw data directory")
@click.option("--rebuild", is_flag=True, help="Drop and rebuild database")
def main(db: str, data: str, rebuild: bool):
    """Load NexaMart data into DuckDB and run transformations."""
    print("\n" + "=" * 60)
    print("NexaMart Pipeline Runner")
    print("=" * 60 + "\n")
    
    db_path = Path(db)
    data_path = Path(data)
    
    # Create db directory if needed
    db_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Delete existing database if rebuild requested
    if rebuild and db_path.exists():
        print(f"Removing existing database: {db_path}")
        db_path.unlink()
    
    # Connect to DuckDB
    print(f"Connecting to {db_path}...")
    conn = duckdb.connect(str(db_path))
    
    try:
        # Load raw data
        load_raw_data(conn, data_path)
        
        # Create staging views
        create_staging_views(conn)
        
        # Run SQL scripts from sql/ directories
        sql_base = Path("sql")
        for subdir in ["staging", "dims", "facts", "views"]:
            sql_path = sql_base / subdir
            if sql_path.exists():
                print(f"\nRunning {subdir} scripts...")
                run_sql_scripts(conn, sql_path)
        
        # Show summary
        show_summary(conn)
        
        print("\n" + "=" * 60)
        print("Pipeline complete!")
        print("=" * 60 + "\n")
        print(f"Database ready at: {db_path}")
        print("Explore with: duckdb " + str(db_path))
        
    finally:
        conn.close()


if __name__ == "__main__":
    main()
