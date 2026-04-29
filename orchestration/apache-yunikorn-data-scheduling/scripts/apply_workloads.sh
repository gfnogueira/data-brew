#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f manifests/team-a-workloads.yaml
kubectl apply -f manifests/team-b-workloads.yaml

echo "Submitted workloads:"
kubectl get jobs -n data-team-a
kubectl get jobs -n data-team-b
