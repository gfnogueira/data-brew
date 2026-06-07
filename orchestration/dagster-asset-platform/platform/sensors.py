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
    materialization = asset_event.dagster_event.event_specific_data.materialization
    partition = materialization.partition or "unpartitioned"
    return RunRequest(
        run_key=f"orders/{partition}/{asset_event.timestamp}",
        partition_key=materialization.partition,
        tags={
            "trigger": "asset_sensor",
            "source_asset": "orders",
            "source_partition": partition,
        },
    )


targeted_marts = AssetSelection.assets("mart_orders", "mart_channel_performance")
