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

## Architecture

```text
Spark SQL / PySpark  --->  Iceberg Catalog  --->  MinIO (S3 warehouse)
         |                         |
         +-------------------------+
                       |
                     Trino
               (analytical queries)
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
└── scripts/
    └── bootstrap.sh
```

## Components

- **MinIO**: S3-compatible object storage for Iceberg data files and metadata
- **Spark**: Engine for table creation and data lifecycle operations
- **Trino**: SQL engine for query and validation

## Prerequisites

- Docker and Docker Compose
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
- Spark Thrift Server: `localhost:10000`

Default credentials:

- MinIO user: `minio`
- MinIO password: `minio123`
