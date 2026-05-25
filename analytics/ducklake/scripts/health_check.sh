#!/usr/bin/env bash
set -euo pipefail

COMPOSE=(docker compose)

section() {
  echo "==> $1"
  shift
  "$@" || true
  echo
}

section "Compose services" \
  "${COMPOSE[@]}" ps

section "Postgres catalog version" \
  "${COMPOSE[@]}" exec -T catalog \
    psql -U "${CATALOG_USER:-ducklake}" -d "${CATALOG_DB:-ducklake_catalog}" \
    -c "SELECT version()"

section "Catalog tables (DuckLake metadata)" \
  "${COMPOSE[@]}" exec -T catalog \
    psql -U "${CATALOG_USER:-ducklake}" -d "${CATALOG_DB:-ducklake_catalog}" \
    -c "SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema') ORDER BY table_schema, table_name"

section "MinIO liveness" \
  curl -fsS http://localhost:9000/minio/health/live && echo

section "Lake bucket contents (top-level)" \
  bash -lc 'docker run --rm --network host minio/mc:RELEASE.2025-02-08T19-14-21Z \
    --json ls "http://${STORAGE_ACCESS_KEY:-minioadmin}:${STORAGE_SECRET_KEY:-minioadmin}@localhost:9000/${STORAGE_BUCKET:-lakehouse}/" 2>/dev/null | head -10'

echo "Health check completed."
