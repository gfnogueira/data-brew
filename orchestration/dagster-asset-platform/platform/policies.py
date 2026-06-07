from datetime import timedelta

from dagster import AutoMaterializePolicy, FreshnessPolicy

# Raw assets are reproducible from scratch on demand; we trigger marts off them
# rather than on a fixed clock, so eager auto-materialize fits well.
raw_eager = AutoMaterializePolicy.eager()

# Curated and dbt-built marts follow the raw layer rather than running ahead of it.
downstream_eager = AutoMaterializePolicy.eager().with_rules()

mart_freshness = FreshnessPolicy(
    maximum_lag_minutes=120,
    cron_schedule="0 * * * *",
)

curated_freshness = FreshnessPolicy(maximum_lag_minutes=30)
