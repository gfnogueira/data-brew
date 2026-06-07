"""Top-level Dagster code location.

Kept intentionally small: the surface that Dagster loads should be obvious at a
glance. New assets, resources, schedules, and sensors are added in their own
modules and re-aggregated here.
"""

from dagster import Definitions

from platform.assets import curated_assets, dbt_assets_collection, raw_assets
from platform.checks import (
    customers_email_is_unique,
    customers_tier_is_known,
    mart_orders_revenue_reconciles,
    orders_refund_share_under_threshold,
)
from platform.jobs import build_marts_job, refresh_raw_job
from platform.resources import dbt_cli, warehouse, warehouse_io_manager
from platform.schedules import hourly_raw_refresh, nightly_marts_build
from platform.sensors import marts_on_new_orders

defs = Definitions(
    assets=[*raw_assets, *curated_assets, *dbt_assets_collection],
    asset_checks=[
        customers_email_is_unique,
        customers_tier_is_known,
        orders_refund_share_under_threshold,
        mart_orders_revenue_reconciles,
    ],
    jobs=[refresh_raw_job, build_marts_job],
    schedules=[hourly_raw_refresh, nightly_marts_build],
    sensors=[marts_on_new_orders],
    resources={
        "warehouse": warehouse,
        "warehouse_io_manager": warehouse_io_manager,
        "dbt": dbt_cli,
    },
)
