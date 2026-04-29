#!/usr/bin/env bash
# Deletes the kind cluster used by the demo.
set -euo pipefail

CLUSTER_NAME="volcano-demo"

echo "==> Deleting kind cluster '${CLUSTER_NAME}'..."
kind delete cluster --name "${CLUSTER_NAME}" || true

echo "==> Done."
