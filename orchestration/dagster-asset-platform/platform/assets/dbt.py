from pathlib import Path

from dagster import AssetExecutionContext
from dagster_dbt import DbtCliResource, dbt_assets

DBT_PROJECT_DIR = Path(__file__).resolve().parents[2] / "dbt_project"

# Manifest is generated on first run via `dbt parse` (see resources.dbt_cli below).
DBT_MANIFEST = DBT_PROJECT_DIR / "target" / "manifest.json"


@dbt_assets(manifest=DBT_MANIFEST)
def asset_platform_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()
