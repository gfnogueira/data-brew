import os
from pathlib import Path

import duckdb
from pyiceberg.catalog import load_catalog


ROOT = Path(__file__).resolve().parent.parent
SQL_DIR = ROOT / "pipeline" / "sql"
os.environ.setdefault("PYICEBERG_HOME", str(ROOT / "config"))


def promote(table: str) -> None:
    cat = load_catalog("nessie")
    bronze = cat.load_table(f"bronze.{table}").scan().to_arrow()

    con = duckdb.connect()
    con.register("src", bronze)
    sql = (SQL_DIR / f"silver_{table}.sql").read_text()
    out = con.execute(sql).fetch_arrow_table()

    full = f"silver.{table}"
    if cat.table_exists(full):
        cat.drop_table(full)
    t = cat.create_table(full, schema=out.schema)
    t.append(out)
    print(f"silver.{table}: wrote {out.num_rows} rows")


if __name__ == "__main__":
    for t in ("customers", "orders"):
        promote(t)
