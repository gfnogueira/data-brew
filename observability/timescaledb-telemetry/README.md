# TimescaleDB Telemetry

Local Proof of Concept for high-volume telemetry storage and analytics on
TimescaleDB running over PostgreSQL.

## Objective

Validate a production-style TimescaleDB pipeline for industrial telemetry with
hypertables, continuous aggregates, and lifecycle policies for compression and
retention.

## Scope

- Single-node TimescaleDB on PostgreSQL 16 tuned for time-series workloads
- Hypertable storage with time-based chunking and composite indexes
- Continuous aggregates for near-realtime rollups
- Compression and retention policies for tiered data lifecycle
- Deterministic load generation and operational query pack

## Architecture

```text
Sensor Producers --> telemetry_raw (hypertable) --> telemetry_1m (cagg) --> telemetry_1h (cagg)
                          (TTL 30d)                    (TTL 90d)              (TTL 365d)
```

## Project Structure

```text
observability/timescaledb-telemetry/
├── docker-compose.yml
├── Makefile
├── README.md
├── requirements.txt
├── .env.example
├── config/
│   └── postgresql.conf
├── sql/
│   ├── schema/
│   └── queries/
└── scripts/
    └── lib/
```

## Bootstrap

```bash
cd observability/timescaledb-telemetry
cp .env.example .env
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
make up
make smoke
```
