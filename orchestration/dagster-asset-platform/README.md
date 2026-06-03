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
└── platform/              Python package loaded by Dagster
    └── definitions.py     Definitions() — assets, resources, jobs, schedules
```
