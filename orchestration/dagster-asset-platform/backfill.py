"""Backfill helper for the daily-partitioned `orders` asset and its descendants.

Usage:
    python backfill.py --start 2026-05-25 --end 2026-06-06

Run from the project root after `dagster dev` has bootstrapped the instance.
"""

from __future__ import annotations

import argparse
from datetime import date, datetime, timedelta

from dagster import DagsterInstance, materialize

from platform.assets.curated import order_lines
from platform.assets.raw import customers, orders, products
from platform.resources import warehouse, warehouse_io_manager


def _daterange(start: date, end: date):
    cursor = start
    while cursor <= end:
        yield cursor
        cursor += timedelta(days=1)


def _parse(value: str) -> date:
    return datetime.fromisoformat(value).date()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--start", required=True, type=_parse)
    parser.add_argument("--end", required=True, type=_parse)
    args = parser.parse_args()

    instance = DagsterInstance.get()

    for day in _daterange(args.start, args.end):
        key = day.isoformat()
        print(f"==> materializing partition {key}")
        materialize(
            assets=[customers, products, orders, order_lines],
            partition_key=key,
            instance=instance,
            resources={
                "warehouse": warehouse,
                "warehouse_io_manager": warehouse_io_manager,
            },
        )

    print("Backfill complete.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
