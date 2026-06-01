#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
export DBT_PROFILES_DIR="$(pwd)/profiles"

ITERATIONS="${BENCH_ITERATIONS:-3}"

bench() {
  local label="$1"
  local selector="$2"
  echo "==> ${label} (x${ITERATIONS})"
  for i in $(seq 1 "$ITERATIONS"); do
    local start_ms end_ms
    start_ms=$(date +%s%3N)
    dbt run --quiet --select "$selector" >/dev/null
    end_ms=$(date +%s%3N)
    echo "  iter ${i}: $((end_ms - start_ms)) ms"
  done
  echo
}

bench "staging only"       "staging"
bench "intermediate+marts" "intermediate marts"
bench "full build"         "+fct_orders"

echo "Benchmark completed."
