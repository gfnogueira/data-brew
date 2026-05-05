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

## Runtime Sequence

```bash
make init       # Apply schema and materialized views
make seed       # Backfill historical events for the configured window
make stream     # Continuous event stream (separate terminal)
make queries    # Run the operational query pack
make validate   # Aggregation freshness, lag, and cross-tier consistency
make health     # Server, table, MV, and async insert health
make bench      # Latency benchmark of the query pack
```

## Query Pack

| File | Purpose |
| --- | --- |
| `01_throughput_per_minute.sql` | Per-minute event throughput and unique sessions |
| `02_active_users_by_platform.sql` | Active users per platform on a 5-minute window |
| `03_regional_latency.sql` | p50/p95/p99 latency by region |
| `04_revenue_by_region.sql` | Hourly revenue by region for purchase events |
| `05_session_funnel.sql` | Session-level funnel and conversion rate |
| `06_error_rate_per_region.sql` | Error rate per region using server-side counters |
| `07_top_users_revenue.sql` | Highest revenue users in the last hour |
