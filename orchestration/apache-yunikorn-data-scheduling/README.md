# Apache YuniKorn Data Scheduling

Production-style Proof of Concept for queue-based workload scheduling on Kubernetes with Apache YuniKorn.

## Objective

Implement deterministic resource governance for data workloads across multiple teams using queue policies, priorities, and namespace placement rules.

## Platform Scope

- Local Kubernetes cluster with Kind
- Apache YuniKorn scheduler on Kubernetes
- Queue hierarchy with team-level capacity control
- Batch workload scheduling with priority classes
- Operational validation and troubleshooting commands

## Repository Structure

```text
orchestration/apache-yunikorn-data-scheduling/
├── README.md
├── Makefile
├── kind/
│   └── cluster.yaml
├── manifests/
│   ├── namespaces.yaml
│   ├── priority-classes.yaml
│   ├── queue-config.yaml
│   ├── team-a-workloads.yaml
│   └── team-b-workloads.yaml
└── scripts/
    ├── bootstrap_kind.sh
    ├── install_yunikorn.sh
    ├── apply_workloads.sh
    ├── validate_scheduling.sh
    └── cleanup.sh
```

## Delivery Plan

### Stage 1: Platform Foundation
- Kind cluster provisioning
- Repository automation targets
- Baseline project structure

### Stage 2: Scheduler and Queue Policies
- YuniKorn installation
- Queue hierarchy and placement rules
- Priority classes for batch execution

### Stage 3: Workload Scheduling Validation
- Team workloads on separate namespaces
- Scheduling and queue placement checks
- Operational runbook commands

## Quick Start

```bash
cd orchestration/apache-yunikorn-data-scheduling
make cluster-up
make install-yunikorn
make apply-policies
make apply-workloads
make validate
```

## Validation Checklist

- YuniKorn scheduler pod is `Running` in namespace `yunikorn`
- Namespaces `data-team-a` and `data-team-b` are mapped to queue labels
- Jobs are created and scheduled in both team namespaces
- Scheduler logs show queue-based placement decisions

## Operational Commands

```bash
make logs
make cleanup
make cluster-down
```
