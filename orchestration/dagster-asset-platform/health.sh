#!/usr/bin/env bash
# Quick eyeball into the moving parts: Postgres backing store, DuckDB warehouse,
# and a snapshot of what the Dagster instance has been doing recently.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

PG_USER="${DAGSTER_PG_USER:-dagster}"
PG_DB="${DAGSTER_PG_DB:-dagster}"
WAREHOUSE="${WAREHOUSE_PATH:-./warehouse.duckdb}"

echo "==> Postgres health"
docker compose exec -T postgres pg_isready -U "$PG_USER" -d "$PG_DB" || true
echo

echo "==> Dagster event log volume"
docker compose exec -T postgres psql -U "$PG_USER" -d "$PG_DB" -At -c \
  "select count(*) || ' events' from event_logs" 2>/dev/null || echo "  (table not yet created — instance hasn't booted)"
echo

echo "==> Recent runs (last 10)"
docker compose exec -T postgres psql -U "$PG_USER" -d "$PG_DB" -c \
  "select run_id, status, create_timestamp from runs order by create_timestamp desc limit 10" \
  2>/dev/null || echo "  (no runs yet)"
echo

echo "==> DuckDB warehouse"
if [[ -f "$WAREHOUSE" ]]; then
  echo "  path: $WAREHOUSE"
  echo "  size: $(du -h "$WAREHOUSE" | cut -f1)"
  duckdb "$WAREHOUSE" -c "
    select table_schema, table_name, estimated_size
    from duckdb_tables()
    where table_schema in ('curated', 'marts', 'stg')
    order by table_schema, table_name
  " 2>/dev/null || true
else
  echo "  warehouse not yet created — materialize the raw layer first"
fi
echo

echo "Health snapshot done."
