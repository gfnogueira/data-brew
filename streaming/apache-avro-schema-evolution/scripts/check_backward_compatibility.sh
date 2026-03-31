#!/usr/bin/env bash
set -euo pipefail

SUBJECT="customer-events-value"
SCHEMA_FILE="$(dirname "$0")/../schemas/customer_event_v2.avsc"
SCHEMA_REGISTRY_URL="http://localhost:8081"

SCHEMA_JSON=$(jq -Rs . < "$SCHEMA_FILE")

echo "Checking BACKWARD compatibility for subject: ${SUBJECT}"

curl -sS -X POST \
  "${SCHEMA_REGISTRY_URL}/compatibility/subjects/${SUBJECT}/versions/latest" \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d "{\"schema\":${SCHEMA_JSON}}" | jq .
