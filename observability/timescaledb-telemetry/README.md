# TimescaleDB Telemetry

High-volume telemetry storage and analytics on TimescaleDB running over PostgreSQL.

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

## Runtime Sequence

```bash
make init       # Extensions, hypertable, indexes, continuous aggregates, refresh policies
make policies   # Compression and retention policies for the tiered lifecycle
make seed       # Backfill historical events for the configured window
make stream     # Continuous event stream (separate terminal)
make queries    # Run the operational query pack
make validate   # Aggregation freshness, lag, and cross-tier consistency
make health     # Hypertable inventory, caggs, background jobs, compression status
make bench      # Latency benchmark of the query pack
```

## Query Pack

| File | Purpose |
| --- | --- |
| `01_throughput_per_minute.sql` | Per-minute throughput and bad sample counts from the 1m cagg |
| `02_active_devices.sql` | Active devices per 5-minute bucket and region |
| `03_sensor_quantiles.sql` | p50/p95/p99 per region, plant, and sensor via percentile sketches |
| `04_gapfill_temperature.sql` | LOCF and linear interpolation for temperature gaps |
| `05_candlestick_voltage.sql` | OHLC candlesticks for voltage over five-minute windows |
| `06_downsample_lttb.sql` | LTTB downsampling for high-resolution device traces |
| `07_chunk_size_breakdown.sql` | Chunk-level size and compression breakdown |
