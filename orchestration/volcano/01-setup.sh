#!/usr/bin/env bash
# Creates the kind cluster used by the demo.
set -euo pipefail

CLUSTER_NAME="volcano-demo"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if kind get clusters 2>/dev/null | grep -qx "${CLUSTER_NAME}"; then
  echo "==> kind cluster '${CLUSTER_NAME}' already exists. Skipping create."
else
  echo "==> Creating kind cluster '${CLUSTER_NAME}' (1 control-plane + 3 workers)..."
  kind create cluster --name "${CLUSTER_NAME}" --config "${HERE}/kind-config.yaml"
fi

kubectl config use-context "kind-${CLUSTER_NAME}"

echo
echo "==> Waiting for nodes to become Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=180s

echo
echo "==> Cluster nodes:"
kubectl get nodes -o wide

echo
echo "==> Ready. Next: ./02-install-volcano.sh"
