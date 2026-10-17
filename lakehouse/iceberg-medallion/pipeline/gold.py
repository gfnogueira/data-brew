import os
from pathlib import Path

import duckdb
from pyiceberg.catalog import load_catalog


ROOT = Path(__file__).resolve().parent.parent
SQL_DIR = ROOT / "pipeline" / "sql"
os.environ.setdefault("PYICEBERG_HOME", str(ROOT / "config"))


def build(table: str) -> None:
    cat = load_catalog("nessie")
    orders = cat.load_table("silver.orders").scan().to_arrow()
    customers = cat.load_table("silver.customers").scan().to_arrow()

    con = duckdb.connect()
    con.register("orders", orders)
    con.register("customers", customers)
    sql = (SQL_DIR / f"gold_{table}.sql").read_text()
    out = con.execute(sql).fetch_arrow_table()

    full = f"gold.{table}"
    if cat.table_exists(full):
        cat.drop_table(full)
    t = cat.create_table(full, schema=out.schema)
    t.append(out)
    print(f"gold.{table}: wrote {out.num_rows} rows")


if __name__ == "__main__":
    for t in ("daily_revenue", "customer_cohort"):
        build(t)
