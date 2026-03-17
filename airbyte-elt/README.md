# Airbyte ELT Platform

Open-source ELT platform for data integration with 300+ pre-built connectors.

## Overview

This project demonstrates Airbyte as a modern ELT (Extract, Load, Transform) platform. It showcases data ingestion from multiple sources into a PostgreSQL data warehouse, ready for downstream transformation with dbt or other tools.

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│    Sources      │ --> │     Airbyte      │ --> │  Destination    │
│  (API, DB, File)│     │   (Orchestrate)  │     │  (PostgreSQL)   │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                               │
                               v
                        ┌─────────────┐
                        │   Web UI    │
                        │  (Config)   │
                        └─────────────┘
```

## Features

- 300+ pre-built connectors
- Incremental sync support
- Schema normalization
- CDC (Change Data Capture)
- Scheduling and monitoring
- REST API for automation
- Terraform provider available

## Project Structure

```
airbyte-elt/
├── docker-compose.yml     # Airbyte services
├── .env                   # Environment configuration
├── sources/
│   ├── sample_data/       # Local file source data
│   │   ├── employees.csv
│   │   ├── departments.csv
│   │   └── salaries.csv
│   └── postgres_init.sql  # Source database setup
├── destinations/
│   └── warehouse_init.sql # Destination schema setup
├── configs/
│   ├── source_file.json   # File source configuration
│   └── destination_pg.json # PostgreSQL destination config
├── Makefile
└── README.md
```

## Requirements

- Docker 20.10+
- Docker Compose 2.0+
- 4GB RAM minimum (8GB recommended)
- 10GB disk space

## Installation

### Quick Start

```bash
cd airbyte-elt
make up
```

### Manual Setup

```bash
# Start Airbyte
docker-compose up -d

# Wait for services (first run takes 2-3 minutes)
docker-compose logs -f airbyte-server

# Access UI
open http://localhost:8000
```

## Usage

### 1. Access Web UI

Open http://localhost:8000

Default credentials:
- Username: airbyte
- Password: password

### 2. Configure Source

Navigate to Sources > New Source:

**File Source (CSV)**
- Source type: File
- Dataset name: employees
- File path: /local/sample_data/employees.csv
- Format: CSV

### 3. Configure Destination

Navigate to Destinations > New Destination:

**PostgreSQL**
- Host: destination-postgres
- Port: 5432
- Database: warehouse
- Username: warehouse_user
- Password: warehouse_password

### 4. Create Connection

Navigate to Connections > New Connection:
- Select source and destination
- Configure sync mode (Full refresh / Incremental)
- Set schedule (Manual / Every X hours)

### 5. Run Sync

Click "Sync Now" to trigger data transfer.

## Sample Data Model

### Source: HR System

**employees.csv**
```
employee_id, first_name, last_name, email, hire_date, department_id, salary
```

**departments.csv**
```
department_id, department_name, manager_id, location
```

**salaries.csv**
```
employee_id, effective_date, salary, currency
```

### Destination: Data Warehouse

Data lands in `raw_data` schema with Airbyte metadata columns:
- `_airbyte_raw_id`
- `_airbyte_extracted_at`
- `_airbyte_loaded_at`

## Sync Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| Full Refresh - Overwrite | Replace all data | Small tables, reference data |
| Full Refresh - Append | Add all data | Audit logs |
| Incremental - Append | Add new records only | Event streams |
| Incremental - Deduped | Upsert based on key | Dimension tables |

## API Usage

### List Sources
```bash
curl -X GET http://localhost:8000/api/v1/sources/list \
  -H "Content-Type: application/json" \
  -d '{"workspaceId": "your-workspace-id"}'
```

### Trigger Sync
```bash
curl -X POST http://localhost:8000/api/v1/connections/sync \
  -H "Content-Type: application/json" \
  -d '{"connectionId": "your-connection-id"}'
```

## Monitoring

### Sync Status

View in UI: Connections > Select Connection > Sync History

### Logs

```bash
# Airbyte server logs
docker-compose logs airbyte-server

# Worker logs (sync execution)
docker-compose logs airbyte-worker
```

## Best Practices

1. **Start with Full Refresh**: Validate data before enabling incremental
2. **Use Staging Schema**: Land raw data in staging, transform separately
3. **Monitor Sync Duration**: Alert on jobs exceeding SLA
4. **Version Connector Updates**: Test in dev before production
5. **Backup Configurations**: Export connection configs regularly

## Integration with dbt

After data lands in warehouse:

```yaml
# dbt sources.yml
sources:
  - name: airbyte_raw
    schema: raw_data
    tables:
      - name: employees
      - name: departments
```

## Troubleshooting

### Container Not Starting

```bash
# Check resources
docker stats

# Increase memory if needed
# Edit docker-compose.yml memory limits
```

### Sync Failing

1. Check source connectivity
2. Verify credentials
3. Review worker logs
4. Check destination permissions
