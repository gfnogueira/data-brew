#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

docker run --rm --network=host \
  -e MC_HOST_local="http://admin:adminpass123@localhost:9000" \
  minio/mc:latest mb -p local/warehouse || true

export PYICEBERG_HOME="$PWD/config"

uv run python - <<'PY'
from pyiceberg.catalog import load_catalog

cat = load_catalog("nessie")
for ns in ("bronze", "silver", "gold"):
    try:
        cat.create_namespace(ns)
        print(f"namespace created: {ns}")
    except Exception as e:
        print(f"namespace exists: {ns} ({e.__class__.__name__})")
PY
