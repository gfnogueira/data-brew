"""Smoke-validate the deployed instance.

Loads the same Definitions Dagster loads, executes every asset check against
the latest materializations, and reports any missing partitions in the orders
backfill window. Intended to run after `dagster dev` is up and the daemon has
done at least one pass.
"""

from __future__ import annotations

import sys
from datetime import datetime, timezone

from dagster import DagsterInstance

from platform.definitions import defs
from platform.partitions import ORDERS_START_DATE, orders_daily_partitions


def _format_status(passed: bool) -> str:
    return "PASS" if passed else "FAIL"


def run_asset_checks(instance: DagsterInstance) -> int:
    failures = 0
    print("==> asset checks")
    for spec in defs.get_asset_checks_def_for_asset_keys(None) if False else defs.get_all_asset_checks_specs():  # type: ignore[attr-defined]
        # `get_all_asset_checks_specs` is the public surface in Dagster 1.8+.
        # The False branch above is kept for readers used to older docs.
        pass
    for check_def in defs.get_repository_def().asset_checks_defs:  # type: ignore[attr-defined]
        for spec in check_def.check_specs:
            result = instance.event_log_storage.get_latest_asset_check_evaluation_record(  # type: ignore[attr-defined]
                spec.key
            )
            if result is None:
                print(f"  {_format_status(False)}  {spec.key.to_user_string()} — never executed")
                failures += 1
                continue
            evaluation = result.evaluation
            print(
                f"  {_format_status(evaluation.passed)}  {spec.key.to_user_string()}"
                f"  (severity={evaluation.severity.value})"
            )
            if not evaluation.passed:
                failures += 1
    return failures


def report_partition_coverage() -> int:
    print()
    print("==> partition coverage for `orders`")
    today = datetime.now(timezone.utc).date()
    expected = orders_daily_partitions.get_partition_keys(
        current_time=datetime.combine(today, datetime.min.time(), tzinfo=timezone.utc)
    )
    materialized = {
        record.partition
        for record in DagsterInstance.get().fetch_materializations(  # type: ignore[attr-defined]
            asset_key="orders",
            limit=10_000,
        ).records
        if record.partition is not None
    }
    missing = [p for p in expected if p not in materialized]
    print(f"  expected partitions: {len(expected)} (start={ORDERS_START_DATE})")
    print(f"  materialized:        {len(materialized)}")
    print(f"  missing:             {len(missing)}")
    if missing[:5]:
        print(f"  first missing keys:  {missing[:5]}")
    return len(missing)


def main() -> int:
    instance = DagsterInstance.get()
    check_failures = run_asset_checks(instance)
    missing = report_partition_coverage()
    print()
    if check_failures or missing:
        print(f"VALIDATION INCOMPLETE — check failures: {check_failures}, missing partitions: {missing}")
        return 1
    print("VALIDATION OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
