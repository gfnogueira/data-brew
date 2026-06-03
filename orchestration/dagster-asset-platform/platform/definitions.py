"""Top-level Dagster code location.

Kept intentionally small: the surface that Dagster loads should be obvious at a
glance. New assets, resources, schedules, and sensors are added in their own
modules and re-aggregated here.
"""

from dagster import Definitions

from platform.assets import curated_assets, raw_assets
from platform.resources import warehouse, warehouse_io_manager

defs = Definitions(
    assets=[*raw_assets, *curated_assets],
    resources={
        "warehouse": warehouse,
        "warehouse_io_manager": warehouse_io_manager,
    },
)
