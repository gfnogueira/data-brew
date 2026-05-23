# DuckLake

Local Proof of Concept for the DuckLake lakehouse specification, built on top
of DuckDB with a PostgreSQL catalog and S3-compatible object storage.

## Objective

Validate a production-style DuckLake deployment that delivers ACID metadata via
Postgres, parquet data files on object storage, snapshot-based time travel, and
maintenance routines for compaction and cleanup.

## Scope

- PostgreSQL 16 as the DuckLake catalog backend
- MinIO as the S3-compatible storage backend with a provisioned bucket
- DuckDB client driving every catalog and table operation through SQL
- Snapshot and time-travel workflows, schema evolution, and concurrent writers
- Maintenance routines for compaction, snapshot expiration, and orphan cleanup

## Architecture

```text
DuckDB Client --> DuckLake extension --> Catalog (PostgreSQL)
                                     +-> Data files (Parquet) --> MinIO (S3)
```

## Project Structure

```text
analytics/ducklake/
├── docker-compose.yml
├── Makefile
├── README.md
├── requirements.txt
├── .env.example
├── config/
│   └── postgresql.conf
├── sql/
│   ├── setup/
│   ├── operations/
│   └── maintenance/
└── scripts/
    └── lib/
```

## Bootstrap

```bash
cd analytics/ducklake
cp .env.example .env
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
make up
make smoke
```
