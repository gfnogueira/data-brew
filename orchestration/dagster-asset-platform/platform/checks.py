import pandas as pd
from dagster import (
    AssetCheckResult,
    AssetCheckSeverity,
    AssetKey,
    asset_check,
)
from dagster_duckdb import DuckDBResource


@asset_check(asset="customers", blocking=True)
def customers_email_is_unique(customers: pd.DataFrame) -> AssetCheckResult:
    duplicates = int(customers["email"].duplicated().sum())
    return AssetCheckResult(
        passed=duplicates == 0,
        metadata={"duplicate_emails": duplicates},
        severity=AssetCheckSeverity.ERROR,
    )


@asset_check(asset="customers")
def customers_tier_is_known(customers: pd.DataFrame) -> AssetCheckResult:
    unknown = sorted(set(customers["tier"]) - {"free", "starter", "pro", "enterprise"})
    return AssetCheckResult(
        passed=not unknown,
        metadata={"unknown_tiers": unknown},
        severity=AssetCheckSeverity.WARN,
    )


@asset_check(asset="orders")
def orders_refund_share_under_threshold(orders: pd.DataFrame) -> AssetCheckResult:
    share = float((orders["status"] == "refunded").mean())
    return AssetCheckResult(
        passed=share < 0.30,
        metadata={"refund_share": share, "threshold": 0.30},
        severity=AssetCheckSeverity.WARN,
    )


@asset_check(asset=AssetKey("mart_orders"))
def mart_orders_revenue_reconciles(warehouse: DuckDBResource) -> AssetCheckResult:
    with warehouse.get_connection() as conn:
        delta = conn.execute(
            """
            select coalesce(sum(gross_cents), 0)
                   - coalesce(sum(net_cents), 0)
                   - coalesce(sum(refunded_cents), 0)
            from marts.mart_orders
            """
        ).fetchone()
    delta_cents = int(delta[0]) if delta else 0
    return AssetCheckResult(
        passed=delta_cents == 0,
        metadata={"unreconciled_cents": delta_cents},
        severity=AssetCheckSeverity.ERROR,
    )
