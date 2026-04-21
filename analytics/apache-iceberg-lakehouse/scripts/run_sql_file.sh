#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: bash scripts/run_sql_file.sh <sql-file>"
  exit 1
fi

SQL_FILE="$1"
if [ ! -f "$SQL_FILE" ]; then
  echo "SQL file not found: $SQL_FILE"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Executing ${SQL_FILE}"

SQL="$(cat "$SQL_FILE")"

docker compose exec -T trino trino \
  --server http://localhost:8080 \
  --user admin \
  --catalog iceberg \
  --schema lakehouse \
  --execute "$SQL"

echo "Execution completed: ${SQL_FILE}"
