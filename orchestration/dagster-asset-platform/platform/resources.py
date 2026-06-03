import os

from dagster_duckdb_pandas import DuckDBPandasIOManager
from dagster_duckdb import DuckDBResource


def _warehouse_path() -> str:
    return os.environ.get("WAREHOUSE_PATH", "./warehouse.duckdb")


warehouse = DuckDBResource(database=_warehouse_path())

warehouse_io_manager = DuckDBPandasIOManager(
    database=_warehouse_path(),
    schema="curated",
)
