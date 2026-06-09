# Dagster Asset Platform

Asset-oriented orchestration PoC built on Dagster. Goal: validate the
software-defined-assets model end to end — Python sources, a DuckDB warehouse,
and a dbt project — with a production-shaped instance backed by Postgres.

## Why this shape

| Decision | Reason |
| --- | --- |
| Postgres for instance storage | Mirrors how Dagster runs in production (event log, run, schedule, sensor storage). SQLite ships by default but is single-writer and hides queue semantics. |
| Daemon on the host, services in compose | `dagster dev` gives hot reload during iteration. Only stateful backing services live in containers. |
| DuckDB as the warehouse | Zero-friction analytical store that lets the same file be queried by Python assets, an IO manager, and dbt without spinning up a second database. |
| dbt embedded in the project | Lets us drive dbt models from the asset graph (`@dbt_assets`) instead of orchestrating dbt as a black-box step. |

## Asset graph at a glance

```
customers ─┐
products ──┼─► orders (daily) ─► order_lines (daily) ─► dbt: stg_order_lines ─► mart_orders ─► mart_channel_performance
           │                                              └─► category_revenue
           └─►
```

## Running locally

```bash
cp .env.example .env
docker compose up -d postgres
export $(grep -v '^#' .env | xargs)
python -m venv .venv && source .venv/bin/activate
pip install -e ".[test]"
(cd dbt_project && dbt deps && dbt parse)
dagster dev -w workspace.yaml
```

The webserver listens on `http://localhost:3000`. Run the daemon in a second
shell for schedules and sensors:

```bash
dagster-daemon run
```

## What runs when

| Trigger | Selector | Cadence |
| --- | --- | --- |
| `hourly_raw_refresh` schedule | `AssetSelection.groups("raw")` | Every hour at minute 5 (UTC) |
| `nightly_marts_build` schedule | curated + dbt asset graph | 03:00 UTC daily |
| `marts_on_new_orders` sensor | curated + dbt assets | Reacts to any `orders` materialization (off by default) |
| Auto-materialize policies | eager on raw and downstream | Continuous, daemon-driven |

## Backfills

`orders` and `order_lines` are partitioned daily. Replay a date range from the
project root once the instance is up:

```bash
python backfill.py --start 2026-05-25 --end 2026-06-06
```

The script materializes each partition through the same resources Dagster uses
in the UI, so backfills are equivalent to clicking through the Launchpad day by
day — only scriptable.

## Validating a deployment

After `dagster dev` and `dagster-daemon run` have completed at least one pass:

```bash
python validate.py    # asset checks + partition coverage
bash health.sh        # Postgres, runs, warehouse snapshot
pytest -q tests       # fast structural tests over Definitions()
```

`validate.py` exits non-zero if any asset check is failing or if the orders
backfill window has gaps. `health.sh` is a read-only eyeball: Postgres health,
recent runs, DuckDB warehouse sizes.

## Layout

```
orchestration/dagster-asset-platform/
├── pyproject.toml             project metadata and dependencies
├── workspace.yaml             Dagster code-location entrypoint
├── config/dagster.yaml        instance configuration (Postgres storage, queue)
├── docker-compose.yml         local Postgres for the Dagster instance
├── dbt_project/               embedded dbt project consumed by @dbt_assets
├── backfill.py                CLI to replay daily partitions
├── validate.py                asset-check and partition-coverage report
├── health.sh                  Postgres + warehouse snapshot
├── tests/                     pytest sanity tests over Definitions()
└── platform/                  Python package loaded by Dagster
    ├── definitions.py         Definitions() — assets, resources, jobs, schedules
    ├── resources.py           DuckDB warehouse + IO manager + DbtCliResource
    ├── jobs.py                refresh_raw_job, build_marts_job
    ├── schedules.py           hourly raw refresh, nightly marts build
    ├── sensors.py             marts_on_new_orders asset sensor
    ├── checks.py              asset checks (uniqueness, reconciliation, thresholds)
    ├── policies.py            auto-materialize and freshness policies
    ├── partitions.py          DailyPartitionsDefinition shared by orders + order_lines
    └── assets/
        ├── raw.py             Python sources (customers, products, orders)
        ├── curated.py         enriched assets persisted in DuckDB via IO manager
        └── dbt.py             dbt models exposed as Dagster assets
```
