#!/usr/bin/env bash
set -euo pipefail

PSQL=(docker compose exec -T timescaledb psql
  -U "${POSTGRES_USER:-telemetry_user}"
  -d "${POSTGRES_DB:-telemetry}"
  -v ON_ERROR_STOP=1
  -X -q -A -t)

ITERATIONS="${BENCH_ITERATIONS:-5}"

bench() {
  local label="$1"
  local file="$2"
  echo "==> ${label} (x${ITERATIONS})"
  for i in $(seq 1 "$ITERATIONS"); do
    "${PSQL[@]}" -c "\\timing on" -f /dev/stdin < "$file" 2>&1 \
      | awk '/^Time:/ {print "  iter '"$i"': " $0}'
  done
  echo
}

bench "throughput per minute"        sql/queries/01_throughput_per_minute.sql
bench "active devices"               sql/queries/02_active_devices.sql
bench "sensor quantiles via sketch"  sql/queries/03_sensor_quantiles.sql
bench "gapfill temperature"          sql/queries/04_gapfill_temperature.sql
bench "candlestick voltage"          sql/queries/05_candlestick_voltage.sql
bench "downsample LTTB"              sql/queries/06_downsample_lttb.sql

echo "Benchmark completed."
