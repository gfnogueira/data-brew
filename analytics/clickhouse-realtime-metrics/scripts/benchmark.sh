#!/usr/bin/env bash
set -euo pipefail

CLIENT=(docker compose exec -T clickhouse clickhouse-client
  --user "${CLICKHOUSE_USER:-metrics_user}"
  --password "${CLICKHOUSE_PASSWORD:-metrics_password}"
  --database "${CLICKHOUSE_DATABASE:-realtime}")

ITERATIONS="${BENCH_ITERATIONS:-5}"

bench() {
  local label="$1"
  local query="$2"
  echo "==> ${label} (x${ITERATIONS})"
  for i in $(seq 1 "$ITERATIONS"); do
    "${CLIENT[@]}" --time --query "$query" >/dev/null
  done
  echo
}

bench "throughput per minute" "$(cat sql/queries/01_throughput_per_minute.sql)"
bench "active users by platform" "$(cat sql/queries/02_active_users_by_platform.sql)"
bench "regional latency quantiles" "$(cat sql/queries/03_regional_latency.sql)"
bench "revenue by region" "$(cat sql/queries/04_revenue_by_region.sql)"
bench "session funnel" "$(cat sql/queries/05_session_funnel.sql)"
bench "error rate per region" "$(cat sql/queries/06_error_rate_per_region.sql)"

echo "Benchmark completed."
