# Avro Schema Evolution

Production-oriented Proof of Concept for schema evolution using Apache Avro, Kafka, and Schema Registry.

## Objective

Validate backward-compatible schema evolution in an event-driven architecture while preserving consumer stability and data contract governance.

## Scope

- Avro-based event serialization
- Central schema governance with Schema Registry
- Producer migration from schema v1 to v2
- Consumer compatibility across schema versions
- Controlled rollout workflow

## Architecture

- Kafka for event transport
- Schema Registry for contract management
- Python producer and consumer using Avro serialization

## Directory Structure

```text
streaming/avro-schema-evolution/
├── docker-compose.yml
├── Makefile
├── requirements.txt
├── schemas/
│   ├── customer_event_v1.avsc
│   └── customer_event_v2.avsc
├── producer/
│   └── producer.py
├── consumer/
│   └── consumer.py
└── scripts/
    ├── register_v1.sh
    └── register_v2.sh
```

## Compatibility Strategy

- Subject: `customer-events-value`
- v1 baseline contract
- v2 adds `risk_tier` with default value to preserve backward compatibility
- Compatibility mode expected: `BACKWARD`

## Part-Based Delivery

### Part 1: Platform and v1 Contract

- Infrastructure (`docker-compose.yml`)
- Baseline Avro schema (`customer_event_v1.avsc`)
- Producer and consumer runtime
- Initial schema registration script
- Project automation (`Makefile`)

### Part 2: Evolution and Validation

- New schema version (`customer_event_v2.avsc`)
- Registration workflow for v2
- Producer update to emit v2 events
- Validation run to confirm compatibility with existing consumer
- Final technical documentation update

## Runbook

```bash
make up
make install
make register-v1
make consume
make produce-v1
```

Then apply evolution:

```bash
make register-v2
make produce-v2
```

## Operational Notes

- Keep one subject per event type
- Enforce compatibility checks before deployment
- Version contracts before producer rollout
- Treat schema changes as controlled releases
