# Operational Runbook

## Service Startup

```bash
make up
make bootstrap
```

## Part 2 Execution

```bash
make run-part2
```

## Part 3 Execution

```bash
make run-part3
```

## Health Checks

- Trino status endpoint:
  - `curl -sSf http://localhost:8080/v1/info`
- MinIO liveness endpoint:
  - `curl -sSf http://localhost:9000/minio/health/live`

## Expected Operational Outcomes

- Namespace and tables available in `iceberg.lakehouse`
- Baseline records inserted
- MERGE upserts applied with expected updates/inserts
- New columns visible after schema evolution
- Snapshot history available for time-travel operations
- Validation queries return stable aggregates and completed-rate metric
