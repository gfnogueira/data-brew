#!/usr/bin/env bash
set -euo pipefail

SUBJECT="customer-events-value"
SCHEMA_REGISTRY_URL="http://localhost:8081"

echo "Subject compatibility:"
curl -sS "${SCHEMA_REGISTRY_URL}/config/${SUBJECT}" | jq .

echo
echo "Registered versions:"
curl -sS "${SCHEMA_REGISTRY_URL}/subjects/${SUBJECT}/versions" | jq .

echo
echo "Latest schema metadata:"
curl -sS "${SCHEMA_REGISTRY_URL}/subjects/${SUBJECT}/versions/latest" | jq .
