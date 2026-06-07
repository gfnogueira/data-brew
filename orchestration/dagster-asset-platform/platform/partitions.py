from dagster import DailyPartitionsDefinition

# Orders are produced daily; everything downstream that wants a per-day cut
# pivots off this single partition definition.
ORDERS_START_DATE = "2026-04-01"

orders_daily_partitions = DailyPartitionsDefinition(
    start_date=ORDERS_START_DATE,
    end_offset=1,
    timezone="UTC",
)
