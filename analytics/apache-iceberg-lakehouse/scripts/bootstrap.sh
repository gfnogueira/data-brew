#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Waiting for MinIO API..."
until curl -sSf http://localhost:9000/minio/health/live >/dev/null; do
  sleep 2
done

echo "Configuring MinIO client and creating warehouse bucket..."
docker compose exec -T minio sh -lc '
  set -euo pipefail
  mc alias set local http://127.0.0.1:9000 "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}" >/dev/null
  mc mb --ignore-existing local/warehouse >/dev/null
'

echo "Waiting for Trino..."
until curl -sSf http://localhost:8080/v1/info >/dev/null; do
  sleep 2
done

echo "Bootstrap complete."
