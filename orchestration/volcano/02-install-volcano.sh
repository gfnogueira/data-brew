#!/usr/bin/env bash
# Installs Volcano via Helm into the volcano-system namespace.
# Pinned to a known stable version for reproducibility.
set -euo pipefail

VOLCANO_VERSION="${VOLCANO_VERSION:-1.10.0}"

echo "==> Installing Volcano v${VOLCANO_VERSION} via Helm..."

helm repo add volcano-sh https://volcano-sh.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update >/dev/null

helm upgrade --install volcano volcano-sh/volcano \
  --namespace volcano-system \
  --create-namespace \
  --version "${VOLCANO_VERSION}" \
  --wait --timeout 5m

echo
echo "==> Volcano components:"
kubectl -n volcano-system get pods

echo
echo "==> Waiting for Volcano CRDs to be Established..."
for crd in jobs.batch.volcano.sh queues.scheduling.volcano.sh podgroups.scheduling.volcano.sh; do
  kubectl wait --for=condition=Established "crd/${crd}" --timeout=60s
done

echo
echo "==> Volcano installed. Next: kubectl apply -f 03-queues.yaml"
