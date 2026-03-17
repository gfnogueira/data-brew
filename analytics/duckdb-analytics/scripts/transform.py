"""
Data transformation pipeline: CSV to Parquet conversion.

Converts raw CSV files to optimized Parquet format with proper
data types, partitioning, and compression settings.
"""

import os
from pathlib import Path

import duckdb
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

RAW_DIR = Path(__file__).parent.parent / "data" / "raw"
PROCESSED_DIR = Path(__file__).parent.parent / "data" / "processed"

# Schema definitions for data validation
SCHEMAS = {
    "products": {
        "product_id": "VARCHAR",
        "product_name": "VARCHAR",
        "category": "VARCHAR",
        "subcategory": "VARCHAR",
        "brand": "VARCHAR",
        "unit_price": "DOUBLE",
        "unit_cost": "DOUBLE",
        "stock_quantity": "INTEGER",
        "is_active": "BOOLEAN",
        "created_at": "DATE",
    },
    "customers": {
        "customer_id": "VARCHAR",
        "first_name": "VARCHAR",
        "last_name": "VARCHAR",
        "email": "VARCHAR",
        "phone": "VARCHAR",
        "segment": "VARCHAR",
        "city": "VARCHAR",
        "state": "VARCHAR",
        "country": "VARCHAR",
        "postal_code": "VARCHAR",
        "registration_date": "DATE",
        "is_active": "BOOLEAN",
    },
    "stores": {
        "store_id": "VARCHAR",
        "store_name": "VARCHAR",
        "region": "VARCHAR",
        "state": "VARCHAR",
        "city": "VARCHAR",
        "address": "VARCHAR",
        "postal_code": "VARCHAR",
        "store_type": "VARCHAR",
        "square_footage": "INTEGER",
        "opened_date": "DATE",
        "manager_name": "VARCHAR",
    },
    "transactions": {
        "transaction_id": "VARCHAR",
        "transaction_date": "TIMESTAMP",
        "customer_id": "VARCHAR",
        "product_id": "VARCHAR",
        "store_id": "VARCHAR",
        "quantity": "INTEGER",
        "unit_price": "DOUBLE",
        "discount_pct": "DOUBLE",
        "total_amount": "DOUBLE",
        "payment_method": "VARCHAR",
        "is_returned": "BOOLEAN",
    },
}


def validate_csv(filepath: Path, schema: dict) -> bool:
    """Validate CSV file exists and has expected columns."""
    if not filepath.exists():
        print(f"  Error: File not found - {filepath}")
        return False

    df = pd.read_csv(filepath, nrows=1)
    missing_cols = set(schema.keys()) - set(df.columns)

    if missing_cols:
        print(f"  Error: Missing columns - {missing_cols}")
        return False

    return True


def convert_to_parquet(
    csv_path: Path,
    parquet_path: Path,
    schema: dict,
    compression: str = "snappy"
) -> dict:
    """
    Convert CSV to Parquet using DuckDB for efficient processing.
    
    Returns statistics about the conversion.
    """
    conn = duckdb.connect()

    # Build column type casting
    type_casts = ", ".join([
        f"CAST({col} AS {dtype}) AS {col}"
        for col, dtype in schema.items()
    ])

    query = f"""
        COPY (
            SELECT {type_casts}
            FROM read_csv_auto('{csv_path}')
        ) TO '{parquet_path}' (FORMAT PARQUET, COMPRESSION {compression})
    """

    conn.execute(query)

    # Get file statistics
    csv_size = csv_path.stat().st_size
    parquet_size = parquet_path.stat().st_size
    compression_ratio = csv_size / parquet_size if parquet_size > 0 else 0

    # Row count
    row_count = conn.execute(
        f"SELECT COUNT(*) FROM read_parquet('{parquet_path}')"
    ).fetchone()[0]

    conn.close()

    return {
        "rows": row_count,
        "csv_size_mb": round(csv_size / (1024 * 1024), 2),
        "parquet_size_mb": round(parquet_size / (1024 * 1024), 2),
        "compression_ratio": round(compression_ratio, 2),
    }


def main():
    """Run the transformation pipeline."""
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

    print("Starting CSV to Parquet transformation\n")
    print("-" * 60)

    total_stats = {
        "files_processed": 0,
        "total_rows": 0,
        "csv_size_mb": 0,
        "parquet_size_mb": 0,
    }

    for table_name, schema in SCHEMAS.items():
        csv_path = RAW_DIR / f"{table_name}.csv"
        parquet_path = PROCESSED_DIR / f"{table_name}.parquet"

        print(f"\nProcessing: {table_name}")

        if not validate_csv(csv_path, schema):
            continue

        stats = convert_to_parquet(csv_path, parquet_path, schema)

        print(f"  Rows: {stats['rows']:,}")
        print(f"  CSV size: {stats['csv_size_mb']} MB")
        print(f"  Parquet size: {stats['parquet_size_mb']} MB")
        print(f"  Compression ratio: {stats['compression_ratio']}x")

        total_stats["files_processed"] += 1
        total_stats["total_rows"] += stats["rows"]
        total_stats["csv_size_mb"] += stats["csv_size_mb"]
        total_stats["parquet_size_mb"] += stats["parquet_size_mb"]

    print("\n" + "-" * 60)
    print("Transformation Summary")
    print(f"  Files processed: {total_stats['files_processed']}")
    print(f"  Total rows: {total_stats['total_rows']:,}")
    print(f"  Total CSV size: {total_stats['csv_size_mb']} MB")
    print(f"  Total Parquet size: {total_stats['parquet_size_mb']} MB")

    if total_stats["parquet_size_mb"] > 0:
        overall_ratio = total_stats["csv_size_mb"] / total_stats["parquet_size_mb"]
        print(f"  Overall compression: {overall_ratio:.2f}x")

    print(f"\nParquet files saved to: {PROCESSED_DIR}")


if __name__ == "__main__":
    main()
