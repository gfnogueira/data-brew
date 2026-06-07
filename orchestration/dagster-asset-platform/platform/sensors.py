from dagster import (
    AssetKey,
    AssetSelection,
    DefaultSensorStatus,
    RunRequest,
    SkipReason,
    asset_sensor,
)

from platform.jobs import build_marts_job

# Whenever a new `orders` materialization lands, rebuild the curated + dbt graph.
@asset_sensor(
    asset_key=AssetKey("orders"),
    job=build_marts_job,
    default_status=DefaultSensorStatus.STOPPED,
    minimum_interval_seconds=30,
)
def marts_on_new_orders(context, asset_event):
    if asset_event is None:
        return SkipReason("waiting for the first orders materialization")
    return RunRequest(
        run_key=str(asset_event.dagster_event.event_specific_data.materialization.tags or asset_event.timestamp),
        tags={
            "trigger": "asset_sensor",
            "source_asset": "orders",
        },
    )


targeted_marts = AssetSelection.assets("mart_orders", "mart_channel_performance")
