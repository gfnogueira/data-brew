from dagster import load_assets_from_package_module

from platform.assets import raw

raw_assets = load_assets_from_package_module(raw, group_name="raw")
