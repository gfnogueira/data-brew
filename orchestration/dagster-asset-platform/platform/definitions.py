"""Top-level Dagster code location.

Kept intentionally small: the surface that Dagster loads should be obvious at a
glance. New assets, resources, schedules, and sensors are added in their own
modules and re-aggregated here.
"""

from dagster import Definitions

defs = Definitions()
