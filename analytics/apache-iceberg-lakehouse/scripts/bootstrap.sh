#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for MinIO API..."
until curl -sSf http://localhost:9000/minio/health/live >/dev/null; do
  sleep 2
done

echo "Creating warehouse bucket..."
docker run --rm --network host \
  -e MC_HOST_local=http://minio:minio123@localhost:9000 \
  minio/mc mb --ignore-existing local/warehouse

echo "Waiting for Trino..."
until curl -sSf http://localhost:8080/v1/info >/dev/null; do
  sleep 2
done

echo "Bootstrap complete."
