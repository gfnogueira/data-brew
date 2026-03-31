#!/usr/bin/env bash
set -euo pipefail

SCHEMA_JSON=$(jq -Rs . < "$(dirname "$0")/../schemas/customer_event_v2.avsc")

curl -sS -X POST "http://localhost:8081/subjects/customer-events-value/versions" \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d "{\"schema\":$SCHEMA_JSON}"

echo
echo "Registered customer_event_v2.avsc"
