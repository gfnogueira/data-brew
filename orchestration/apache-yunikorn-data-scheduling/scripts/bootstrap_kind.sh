#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v kind >/dev/null 2>&1; then
  echo "kind binary is required."
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl binary is required."
  exit 1
fi

if kind get clusters | grep -q "^data-yunikorn$"; then
  echo "Cluster data-yunikorn already exists."
else
  kind create cluster --config kind/cluster.yaml
fi

kubectl cluster-info >/dev/null
echo "Kind cluster is ready."
