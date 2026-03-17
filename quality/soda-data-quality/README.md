# Soda Data Quality

Data quality solution for the raw layer using Soda Core. Scans tables and columns with SodaCL checks before data reaches transformation (dbt) or analytics.

## Overview

This project implements Soda Core as the quality gate for raw and staging data. It complements dbt + Elementary by validating data at ingestion and source level, so quality issues are caught before they propagate to downstream models.

## Architecture

```
                    Raw Layer                Transform Layer
┌─────────────────────────────┐     ┌─────────────────────────────┐
│  Source (PostgreSQL)         │     │  dbt + Elementary           │
│  ├── raw.customers           │ --> │  (staging, marts)          │
│  ├── raw.orders              │     │  (model quality)           │
│  └── raw.products            │     └─────────────────────────────┘
│           │                           │
│           v                           │
│  ┌─────────────────┐                  │
│  │  Soda Core      │  Quality gate    │
│  │  (this PoC)     │  at raw layer    │
│  └─────────────────┘                  │
└───────────────────────────────────────┘
```

## Features

- Table-level checks (row count, freshness)
- Column-level checks (nulls, duplicates, validity, ranges)
- Schema change detection
- YAML-based check definitions (SodaCL)
- Local scans (no Soda Cloud required)
- CI/CD ready (exit code on failure)

## Project Structure

```
soda-data-quality/
├── configuration.yml       # Data source connection
├── checks/
│   ├── raw_customers.yml
│   ├── raw_orders.yml
│   └── raw_products.yml
├── scripts/
│   └── init.sql            # Raw schema and sample data
├── docker-compose.yml
├── requirements.txt
├── Makefile
├── README.md
└── ESTUDO.md
```

## Requirements

- Python 3.9+
- Docker and Docker Compose (for PostgreSQL)
- Soda Core PostgreSQL adapter

## Installation

```bash
cd soda-data-quality
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Usage

### Start Database

```bash
make up
```

### Run All Scans

```bash
make scan
```

### Run Single Table Scan

```bash
soda scan -d raw_warehouse -c configuration.yml checks/raw_customers.yml
```

### Run Scan (Local Only, No Cloud)

```bash
make scan-local
```

### Stop Database

```bash
make down
```

## Check Types Demonstrated

| Check | Purpose |
|-------|---------|
| row_count | Volume validation |
| missing_count / missing_percent | Null checks |
| invalid_count | Format validation (e.g. email) |
| duplicate_count | Uniqueness |
| schema | Detect schema drift |
| freshness | Data freshness (optional) |

## Integration with Elementary

- **Soda**: Raw and staging tables; format, nulls, duplicates, schema.
- **Elementary**: dbt models; anomalies, lineage, run history.

Run Soda after load, before or in parallel with dbt. Fail the pipeline if Soda checks fail.

