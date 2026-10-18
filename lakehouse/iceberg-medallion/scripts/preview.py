import os
from pathlib import Path

from pyiceberg.catalog import load_catalog


ROOT = Path(__file__).resolve().parent.parent
os.environ.setdefault("PYICEBERG_HOME", str(ROOT / "config"))


def preview(table: str, limit: int = 10) -> None:
    cat = load_catalog("nessie")
    df = cat.load_table(table).scan(limit=limit).to_pandas()
    print(f"\n=== {table}")
    print(df.to_string(index=False))


if __name__ == "__main__":
    preview("gold.daily_revenue")
    preview("gold.customer_cohort")
