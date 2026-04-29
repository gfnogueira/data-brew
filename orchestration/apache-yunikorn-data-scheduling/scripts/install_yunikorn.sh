#!/usr/bin/env bash
set -euo pipefail

if ! command -v helm >/dev/null 2>&1; then
  echo "helm binary is required."
  exit 1
fi

kubectl get namespace yunikorn >/dev/null 2>&1 || kubectl create namespace yunikorn

helm repo add yunikorn https://apache.github.io/yunikorn-release >/dev/null
helm repo update >/dev/null

helm upgrade --install yunikorn yunikorn/yunikorn \
  --namespace yunikorn \
  --wait \
  --timeout 5m

echo "YuniKorn installation completed."
