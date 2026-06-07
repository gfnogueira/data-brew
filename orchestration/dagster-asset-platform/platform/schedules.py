from dagster import ScheduleDefinition

from platform.jobs import build_marts_job, refresh_raw_job

# Raw assets are cheap to regenerate; the curated + dbt graph runs every hour
# off the back of fresh raw data plus the sensor wiring in sensors.py.
hourly_raw_refresh = ScheduleDefinition(
    name="hourly_raw_refresh",
    job=refresh_raw_job,
    cron_schedule="5 * * * *",
    execution_timezone="UTC",
)

nightly_marts_build = ScheduleDefinition(
    name="nightly_marts_build",
    job=build_marts_job,
    cron_schedule="0 3 * * *",
    execution_timezone="UTC",
)
