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

## Running locally

```bash
cp .env.example .env
docker compose up -d postgres
export $(grep -v '^#' .env | xargs)
python -m venv .venv && source .venv/bin/activate
pip install -e .
dagster dev -w workspace.yaml
```

The webserver listens on `http://localhost:3000`. Run the daemon in a second
shell for schedules and sensors:

```bash
dagster-daemon run
```

## Layout

```
orchestration/dagster-asset-platform/
├── pyproject.toml         project metadata and dependencies
├── workspace.yaml         Dagster code-location entrypoint
├── config/dagster.yaml    instance configuration (Postgres storage, queue)
├── docker-compose.yml     local Postgres for the Dagster instance
├── dbt_project/           embedded dbt project consumed by @dbt_assets
└── platform/              Python package loaded by Dagster
    ├── definitions.py     Definitions() — assets, resources, jobs, schedules
    ├── resources.py       DuckDB warehouse + IO manager + DbtCliResource
    └── assets/
        ├── raw.py         Python sources (customers, products, orders)
        ├── curated.py     enriched assets persisted in DuckDB via IO manager
        └── dbt.py         dbt models exposed as Dagster assets
```

## Bringing the dbt graph online

The dbt project is parsed on the first dev session so Dagster can read its
manifest:

```bash
(cd dbt_project && dbt deps && dbt parse)
dagster dev -w workspace.yaml
```

After that, dbt models appear alongside the Python assets in the asset graph,
sharing the same DuckDB warehouse as backing storage.

## Backfills

`orders` and `order_lines` are partitioned daily. Replay a date range from the
project root once the instance is up:

```bash
python backfill.py --start 2026-05-25 --end 2026-06-06
```

The script materializes each partition through the same resources Dagster uses
in the UI, so backfills are equivalent to clicking through the Launchpad day by
day — only scriptable.
