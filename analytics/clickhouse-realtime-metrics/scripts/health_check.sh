#!/usr/bin/env bash
set -euo pipefail

CLIENT=(docker compose exec -T clickhouse clickhouse-client
  --user "${CLICKHOUSE_USER:-metrics_user}"
  --password "${CLICKHOUSE_PASSWORD:-metrics_password}"
  --database "${CLICKHOUSE_DATABASE:-realtime}")

section() {
  echo "==> $1"
  shift
  "${CLIENT[@]}" "$@"
  echo
}

section "Server identity" \
  --query "SELECT version() AS version, uptime() AS uptime_seconds, currentUser() AS user"

section "Table sizes and part counts" \
  --query "
    SELECT
      table,
      formatReadableSize(sum(bytes_on_disk)) AS size,
      sum(rows)                              AS rows,
      count()                                AS parts
    FROM system.parts
    WHERE database = currentDatabase() AND active
    GROUP BY table
    ORDER BY sum(bytes_on_disk) DESC
    FORMAT PrettyCompact
  "

section "Materialized view dependencies" \
  --query "
    SELECT
      database,
      name AS view,
      engine,
      as_select
    FROM system.tables
    WHERE database = currentDatabase() AND engine = 'MaterializedView'
    FORMAT Vertical
  "

section "Async insert queue health" \
  --query "
    SELECT
      table,
      status,
      bytes,
      rows,
      query_id,
      flush_time
    FROM system.asynchronous_insert_log
    WHERE event_time >= now() - INTERVAL 10 MINUTE
    ORDER BY event_time DESC
    LIMIT 10
    FORMAT PrettyCompact
  "

section "Recent failed queries" \
  --query "
    SELECT
      event_time,
      query_duration_ms,
      exception
    FROM system.query_log
    WHERE event_time >= now() - INTERVAL 30 MINUTE
      AND type = 'ExceptionWhileProcessing'
    ORDER BY event_time DESC
    LIMIT 10
    FORMAT PrettyCompact
  "

echo "Health check completed."
