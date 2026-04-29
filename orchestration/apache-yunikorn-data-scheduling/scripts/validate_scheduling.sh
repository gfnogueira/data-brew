#!/usr/bin/env bash
set -euo pipefail

echo "Scheduler deployment status:"
kubectl get pods -n yunikorn

echo
echo "Team A jobs:"
kubectl get jobs,pods -n data-team-a

echo
echo "Team B jobs:"
kubectl get jobs,pods -n data-team-b

echo
echo "Queue assignment labels:"
kubectl get ns data-team-a -o jsonpath='{.metadata.labels.yunikorn\.apache\.org/queue}'; echo
kubectl get ns data-team-b -o jsonpath='{.metadata.labels.yunikorn\.apache\.org/queue}'; echo

echo
echo "Recent scheduler logs:"
kubectl logs -n yunikorn -l app=yunikorn-scheduler --tail=100
