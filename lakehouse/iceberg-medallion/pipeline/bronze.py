import os
import sys
from pathlib import Path

import pyarrow.csv as pacsv
from pyiceberg.catalog import load_catalog


ROOT = Path(__file__).resolve().parent.parent
os.environ.setdefault("PYICEBERG_HOME", str(ROOT / "config"))


def ingest(seed_file: str, table: str) -> None:
    path = ROOT / "seeds" / seed_file
    arrow_table = pacsv.read_csv(path)

    cat = load_catalog("nessie")
    full = f"bronze.{table}"

    if cat.table_exists(full):
        t = cat.load_table(full)
        t.append(arrow_table)
        action = "appended"
    else:
        t = cat.create_table(full, schema=arrow_table.schema)
        t.append(arrow_table)
        action = "created"

    print(f"bronze.{table}: {action} {arrow_table.num_rows} rows from {seed_file}")


if __name__ == "__main__":
    args = sys.argv[1:] or ["customers.csv:customers", "orders_2026_10_15.csv:orders", "orders_2026_10_16.csv:orders"]
    for arg in args:
        seed, tbl = arg.split(":")
        ingest(seed, tbl)
