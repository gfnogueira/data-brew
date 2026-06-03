from dagster import load_assets_from_package_module

from platform.assets import curated, raw
from platform.assets.dbt import asset_platform_dbt_assets

raw_assets = load_assets_from_package_module(raw, group_name="raw")
curated_assets = load_assets_from_package_module(curated, group_name="curated")
dbt_assets_collection = [asset_platform_dbt_assets]
