#!/usr/bin/env bash
set -euo pipefail

export DBT_PROFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/profiles"

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "==> dbt deps"
dbt deps

echo
echo "==> dbt seed"
dbt seed --full-refresh

echo
echo "==> dbt run"
dbt run

echo
echo "==> dbt snapshot"
dbt snapshot

echo
echo "==> dbt test"
dbt test

echo
echo "==> dbt docs generate"
dbt docs generate

echo
echo "Pipeline completed."
