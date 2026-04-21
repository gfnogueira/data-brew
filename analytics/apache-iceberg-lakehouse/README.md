# Apache Iceberg Lakehouse

Local lakehouse Proof of Concept using Apache Iceberg with Spark, Trino, and MinIO.

## Objective

Establish a production-style foundation for Iceberg table management and analytical querying on object storage.

## Scope (Part 1)

- Local object storage with S3-compatible API (MinIO)
- Iceberg catalog and warehouse configuration
- Spark runtime for table operations
- Trino runtime for analytical SQL access
- Automated bootstrap workflow

## Scope (Part 2)

- Namespace and Iceberg table creation
- Baseline ingestion workflows
- Merge-based upsert workflows

## Scope (Part 3)

- Schema evolution operations
- Snapshot and time-travel validation
- Operational runbook and release controls

## Architecture

```text
Trino SQL  --->  Iceberg REST Catalog  --->  MinIO (S3 warehouse)
```

## Project Structure

```text
analytics/apache-iceberg-lakehouse/
├── docker-compose.yml
├── Makefile
├── README.md
├── conf/
│   └── trino/
│       └── catalog/
│           └── iceberg.properties
├── docs/
│   ├── operational-runbook.md
│   └── release-controls.md
├── sql/
│   ├── 01_create_namespace_and_tables.sql
│   ├── 02_ingest_baseline_data.sql
│   ├── 03_merge_upserts.sql
│   ├── 04_schema_evolution.sql
│   ├── 05_time_travel_and_rollback.sql
│   └── 06_trino_validation_queries.sql
└── scripts/
    ├── bootstrap.sh
    └── run_sql_file.sh
```

## Components

- **MinIO**: S3-compatible object storage for Iceberg data files and metadata
- **Iceberg REST Catalog**: REST-based catalog service for Iceberg metadata
- **Trino**: SQL engine for table lifecycle operations and validation

## Prerequisites

- Docker and Docker Compose v2 (`docker compose`)
- `bash`
- `curl`

## Quick Start

```bash
cd analytics/apache-iceberg-lakehouse
make up
make bootstrap
make status
```

## Access

- MinIO API: `http://localhost:9000`
- MinIO Console: `http://localhost:9001`
- Trino: `http://localhost:8080`

Default credentials:

- MinIO user: `minio`
- MinIO password: `minio123`

## Execution

### Platform startup

```bash
make up
make bootstrap
```

### Part 2 workflow

```bash
make run-part2
```

### Part 3 workflow

```bash
make run-part3
```

### Full validation sequence

```bash
make validate-all
```

## Validation and Control Artifacts

- `docs/operational-runbook.md`
- `docs/release-controls.md`
