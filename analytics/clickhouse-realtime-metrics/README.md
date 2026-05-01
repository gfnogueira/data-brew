# ClickHouse Realtime Metrics

Local Proof of Concept for high-throughput event ingestion and low-latency
operational metric queries on ClickHouse.

## Objective

Validate a production-style ClickHouse pipeline for realtime metrics with
clear separation between ingestion, storage, aggregation, and query layers.

## Scope

- Single-node ClickHouse runtime tuned for realtime workloads
- Raw event store with retention policy
- Tiered aggregation pipeline driven by materialized views
- Deterministic load generation for reproducible runs
- Query pack and validation workflow for operational dashboards

## Architecture

```text
Event Producers --> user_events_raw --> metrics_1m --> metrics_5m --> metrics_daily
                          (TTL 7d)        (MV)          (MV)          (MV)
```

## Project Structure

```text
analytics/clickhouse-realtime-metrics/
├── docker-compose.yml
├── Makefile
├── README.md
├── requirements.txt
├── .env.example
├── config/
│   ├── server-settings.xml
│   └── users.xml
├── sql/
│   ├── schema/
│   └── queries/
└── scripts/
    └── lib/
```

## Bootstrap

```bash
cd analytics/clickhouse-realtime-metrics
cp .env.example .env
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
make up
make smoke
```
