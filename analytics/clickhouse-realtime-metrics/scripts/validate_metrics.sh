#!/usr/bin/env bash
set -euo pipefail

CLIENT=(docker compose exec -T clickhouse clickhouse-client
  --user "${CLICKHOUSE_USER:-metrics_user}"
  --password "${CLICKHOUSE_PASSWORD:-metrics_password}"
  --database "${CLICKHOUSE_DATABASE:-realtime}")

run() {
  local title="$1"
  shift
  echo "==> ${title}"
  "${CLIENT[@]}" "$@"
  echo
}

run "Raw event volume in the last 30 minutes" \
  --query "SELECT count() AS events FROM user_events_raw WHERE event_time >= now() - INTERVAL 30 MINUTE"

run "Aggregation freshness lag (seconds)" \
  --query "
    WITH
      (SELECT max(event_time) FROM user_events_raw) AS raw_max,
      (SELECT max(window_start) FROM metrics_1m)    AS agg_max
    SELECT
      raw_max,
      agg_max,
      dateDiff('second', agg_max, raw_max) AS lag_seconds
  "

run "Recent 1-minute aggregation windows" \
  --query "
    SELECT
      window_start,
      countMerge(events_count) AS events,
      uniqMerge(unique_users)  AS users
    FROM metrics_1m
    WHERE window_start >= now() - INTERVAL 15 MINUTE
    GROUP BY window_start
    ORDER BY window_start DESC
    LIMIT 10
    FORMAT PrettyCompact
  "

run "Cross-tier consistency (5m vs 1m, last 30 minutes)" \
  --query "
    WITH
      (SELECT countMerge(events_count) FROM metrics_1m WHERE window_start >= now() - INTERVAL 30 MINUTE) AS events_1m,
      (SELECT countMerge(events_count) FROM metrics_5m WHERE window_start >= now() - INTERVAL 30 MINUTE) AS events_5m
    SELECT events_1m, events_5m, abs(events_1m - events_5m) AS delta
  "

echo "Validation completed."
