# Volcano Batch Scheduling Demo

Hands-on Kubernetes demo of gang scheduling with [Volcano](https://volcano.sh).
Runs locally on `kind` with Docker Desktop **or Colima**.

## What you'll see

| Scenario | Workload | Outcome |
|----------|----------|---------|
| A | Small gang-scheduled job | 3 pods Running together |
| B | Heavy gang-scheduled job that does not fit | All 6 pods stay Pending — Volcano refuses partial scheduling |
| C | Same heavy job, default Kubernetes scheduler | ~3 Running + ~3 Pending — partial chaos |

The contrast between scenarios B and C is what Volcano fixes.

---

## Requirements

| Tool | Version | Install |
|------|---------|---------|
| Docker engine (Docker Desktop or Colima) | 20+ | https://docs.docker.com/get-docker/ or `brew install colima docker` |
| kind | 0.20+ | `brew install kind` |
| kubectl | 1.27+ | `brew install kubectl` |
| helm | 3.10+ | `brew install helm` |

The container engine needs at least **4 CPU and 8 GiB RAM** allocated. The overflow scenario reserves 30 GiB of memory in K8s scheduler accounting (actual host RAM use stays under 2 GiB because the demo containers only run `sleep`).

### Colima setup

If you're using Colima:

```bash
colima start --cpu 4 --memory 8 --disk 20
```

Confirm Docker is reachable:

```bash
docker info
```

If Docker Desktop is installed alongside Colima, only one needs to be running at a time.

---

## Run the demo

```bash
./00-prereqs.sh                                # check tools and engine
./01-setup.sh                                  # create kind cluster
./02-install-volcano.sh                        # install Volcano via Helm
kubectl apply -f 03-queues.yaml                # queues + namespace
kubectl apply -f 04-vcjob-gang-ok.yaml         # scenario A
kubectl apply -f 05-vcjob-gang-overflow.yaml   # scenario B
kubectl apply -f 06-deployment-default.yaml    # scenario C
```

### Inspect

```bash
# Pods overall
kubectl get pods -n lakehouse-batch -o wide

# Volcano gang state
kubectl get podgroup -n lakehouse-batch
kubectl describe podgroup -n lakehouse-batch \
  $(kubectl get podgroup -n lakehouse-batch -o name | grep quarterly-revenue-rebuild)

# Live watch
kubectl get pods -n lakehouse-batch -w
```

### Cleanup

```bash
./99-cleanup.sh
```

---

## Files

| File | Purpose |
|------|---------|
| `kind-config.yaml` | Cluster shape: 1 control-plane + 3 workers |
| `00-prereqs.sh` | Verifies tools, container engine, and resource allocation |
| `01-setup.sh` | Creates the kind cluster |
| `02-install-volcano.sh` | Installs Volcano via Helm (pinned to v1.10.0) |
| `03-queues.yaml` | `gold-tier` + `silver-tier` queues + `lakehouse-batch` namespace |
| `04-vcjob-gang-ok.yaml` | `daily-orders-rollup` — 3 executors, gang-scheduled, fits |
| `05-vcjob-gang-overflow.yaml` | `quarterly-revenue-rebuild` — 6 executors, 30 GiB total, overflows |
| `06-deployment-default.yaml` | `quarterly-revenue-naive` — same workload via default scheduler |
| `99-cleanup.sh` | Deletes the kind cluster |

---
