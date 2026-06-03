import os
from pathlib import Path

from dagster_dbt import DbtCliResource
from dagster_duckdb_pandas import DuckDBPandasIOManager
from dagster_duckdb import DuckDBResource


def _warehouse_path() -> str:
    return os.environ.get("WAREHOUSE_PATH", "./warehouse.duckdb")


warehouse = DuckDBResource(database=_warehouse_path())

warehouse_io_manager = DuckDBPandasIOManager(
    database=_warehouse_path(),
    schema="curated",
)

DBT_PROJECT_DIR = Path(__file__).resolve().parents[1] / "dbt_project"

dbt_cli = DbtCliResource(
    project_dir=str(DBT_PROJECT_DIR),
    profiles_dir=str(DBT_PROJECT_DIR),
)
