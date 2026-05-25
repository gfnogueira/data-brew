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

## Runtime Sequence

```bash
make init         # Attach lake and create base tables
make seed         # Seed users and events through pure SQL
make mutate       # Apply updates, deletes, and inserts to produce snapshots
make snapshots    # Inspect snapshot history and run time-travel queries
make evolution    # Apply schema evolution (add, rename, widen columns)
make concurrent   # Run parallel writers backed by the Postgres catalog
make maintenance  # Compact files, expire snapshots, and cleanup orphans
make validate     # Assert catalog state, tables, snapshots, and files
make bench        # Measure latency across read paths including time travel
make health       # Inspect compose services, catalog, storage, and bucket
```

## Operations Catalog

| File | Purpose |
| --- | --- |
| `sql/setup/00_extensions.sql` | Install and load ducklake, postgres, httpfs |
| `sql/setup/01_storage_secret.sql` | Register the S3 secret for MinIO |
| `sql/setup/02_attach_lake.sql` | Attach the lake against the catalog and data path |
| `sql/setup/03_create_tables.sql` | Define users and events tables |
| `sql/operations/01_seed_initial.sql` | Bulk-load deterministic users and events |
| `sql/operations/02_mutations.sql` | Updates, deletes, and inserts to produce snapshots |
| `sql/operations/03_time_travel.sql` | Snapshots listing and AT VERSION / AT TIMESTAMP reads |
| `sql/operations/04_changes_inspection.sql` | Per-table change history and file inventory |
| `sql/operations/05_schema_evolution.sql` | Add, drop, rename, and widen columns |
| `sql/maintenance/01_compaction.sql` | Merge adjacent data files toward target size |
| `sql/maintenance/02_expire_snapshots.sql` | Expire snapshots by age and retention count |
| `sql/maintenance/03_cleanup_orphans.sql` | Dry-run plus actual orphan file cleanup |
