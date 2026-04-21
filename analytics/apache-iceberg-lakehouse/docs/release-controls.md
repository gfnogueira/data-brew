# Release Controls

## Change Control Policy

- Treat schema changes as release artifacts
- Require compatibility and query validation prior to promotion
- Record snapshot identifiers for rollback readiness

## Pre-Release Checklist

1. All SQL lifecycle scripts run successfully
2. Snapshot metadata confirms expected operations
3. Aggregation and join validations pass without null regressions
4. Time-travel query executes against latest snapshot lineage

## Rollback Strategy

1. Identify stable snapshot from `orders$snapshots`
2. Execute rollback command in controlled window
3. Re-run validation queries after rollback

Rollback command pattern:

```sql
ALTER TABLE iceberg.lakehouse.orders
EXECUTE rollback_to_snapshot(snapshot_id => <snapshot_id>);
```

## Post-Release Validation

- Compare total row counts and business aggregates before/after release
- Confirm no schema drift outside approved changes
- Confirm query latency remains within acceptable local baseline
