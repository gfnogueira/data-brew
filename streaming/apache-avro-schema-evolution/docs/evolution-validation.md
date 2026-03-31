# Schema Evolution Validation

This document defines the validation workflow for contract evolution from `customer_event_v1` to `customer_event_v2`.

## Validation Objectives

- Confirm backward compatibility before schema registration
- Confirm subject-level compatibility policy
- Confirm multi-version registration history
- Confirm runtime consumption after producer migration

## Pre-conditions

- Kafka and Schema Registry are running
- v1 schema is registered under `customer-events-value`
- Consumer process is active

## Validation Flow

1. Check subject policy and version history
2. Run backward compatibility check for v2
3. Register v2 schema
4. Produce v2 event payload
5. Confirm consumer deserialization and output

## Commands

```bash
make subject-status
make check-compatibility
make register-v2
make produce-v2
```

## Acceptance Criteria

- Compatibility check returns `"is_compatible": true`
- Subject remains configured with `BACKWARD` policy
- Subject versions list includes both v1 and v2
- Consumer processes new events without deserialization errors

## Operational Guidance

- Do not register new schema versions without compatibility verification
- Keep one subject per event contract family
- Treat schema changes as release-managed contract updates
