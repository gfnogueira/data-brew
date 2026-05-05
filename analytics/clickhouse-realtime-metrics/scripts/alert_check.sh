#!/usr/bin/env bash
set -euo pipefail

CLIENT=(docker compose exec -T clickhouse clickhouse-client
  --user "${CLICKHOUSE_USER:-metrics_user}"
  --password "${CLICKHOUSE_PASSWORD:-metrics_password}"
  --database "${CLICKHOUSE_DATABASE:-realtime}")

LATENCY_THRESHOLD_MS="${ALERT_LATENCY_P95_MS:-1500}"
TRAFFIC_MIN_RATIO="${ALERT_TRAFFIC_MIN_RATIO:-0.5}"
REVENUE_MIN_RATIO="${ALERT_REVENUE_MIN_RATIO:-0.6}"
ERROR_MAX_RATE="${ALERT_ERROR_MAX_RATE:-0.05}"

EXIT_CODE=0

evaluate() {
  local label="$1"
  local file="$2"
  shift 2
  echo "==> ${label}"
  local output
  output=$("${CLIENT[@]}" --queries-file "$file" "$@" --format PrettyCompact)
  echo "${output}"
  if [[ -n "${output//[[:space:]]/}" ]]; then
    case "${label}" in
      "traffic drop"|"revenue drop")
        if grep -qE '\b1\b' <<<"${output}"; then
          echo "ALERT: ${label} triggered"
          EXIT_CODE=1
        fi
        ;;
      *)
        echo "ALERT: ${label} triggered"
        EXIT_CODE=1
        ;;
    esac
  fi
  echo
}

evaluate "latency spike (p95)" sql/alerts/01_latency_spike.sql \
  --param_threshold_ms="${LATENCY_THRESHOLD_MS}"

evaluate "traffic drop" sql/alerts/02_traffic_drop.sql \
  --param_min_ratio="${TRAFFIC_MIN_RATIO}"

evaluate "revenue drop" sql/alerts/03_revenue_drop.sql \
  --param_min_ratio="${REVENUE_MIN_RATIO}"

evaluate "error burst" sql/alerts/04_error_burst.sql \
  --param_max_rate="${ERROR_MAX_RATE}"

if [[ "${EXIT_CODE}" -ne 0 ]]; then
  echo "One or more alerts triggered."
else
  echo "All alerts within thresholds."
fi

exit "${EXIT_CODE}"
