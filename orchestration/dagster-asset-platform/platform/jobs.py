from dagster import AssetSelection, define_asset_job

# Two named jobs so schedules and sensors have stable handles to target.
refresh_raw_job = define_asset_job(
    name="refresh_raw",
    selection=AssetSelection.groups("raw"),
)

build_marts_job = define_asset_job(
    name="build_marts",
    selection=AssetSelection.groups("curated") | AssetSelection.assets("asset_platform_dbt_assets"),
)
