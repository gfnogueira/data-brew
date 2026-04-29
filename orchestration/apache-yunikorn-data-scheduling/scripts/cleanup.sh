#!/usr/bin/env bash
set -euo pipefail

kubectl delete -f manifests/team-a-workloads.yaml --ignore-not-found
kubectl delete -f manifests/team-b-workloads.yaml --ignore-not-found
kubectl delete -f manifests/queue-config.yaml --ignore-not-found
kubectl delete -f manifests/priority-classes.yaml --ignore-not-found
kubectl delete -f manifests/namespaces.yaml --ignore-not-found

echo "Kubernetes resources removed."
