from dagster import load_assets_from_package_module

from platform.assets import curated, raw

raw_assets = load_assets_from_package_module(raw, group_name="raw")
curated_assets = load_assets_from_package_module(curated, group_name="curated")
