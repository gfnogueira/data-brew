# Elementary Data Observability

Data observability solution using Elementary with dbt for automated monitoring, anomaly detection, and data quality alerts.

## Overview

This project demonstrates how to implement data observability in a dbt project using Elementary. It provides automated data quality monitoring, lineage tracking, and anomaly detection without requiring external infrastructure.

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Source Data   │ --> │   dbt + Models   │ --> │   Elementary    │
│   (PostgreSQL)  │     │   (Transform)    │     │   (Observe)     │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                                         │
                                                         v
                                                 ┌───────────────┐
                                                 │   Reports &   │
                                                 │    Alerts     │
                                                 └───────────────┘
```

## Features

- Automated data quality tests
- Anomaly detection for metrics
- Data freshness monitoring
- Schema change detection
- Column-level lineage
- Self-service HTML reports
- Slack/Email alerting

## Project Structure

```
elementary-data/
├── dbt_project/
│   ├── models/
│   │   ├── staging/
│   │   │   ├── stg_orders.sql
│   │   │   ├── stg_customers.sql
│   │   │   └── stg_products.sql
│   │   ├── marts/
│   │   │   ├── fct_orders.sql
│   │   │   └── dim_customers.sql
│   │   └── schema.yml
│   ├── seeds/
│   │   ├── raw_orders.csv
│   │   ├── raw_customers.csv
│   │   └── raw_products.csv
│   ├── dbt_project.yml
│   ├── packages.yml
│   └── profiles.yml
├── docker-compose.yml
├── scripts/
│   ├── init.sql
│   └── run_pipeline.sh
├── Makefile
├── README.md
└── ESTUDO.md
```

## Requirements

- Docker and Docker Compose
- Python 3.9+
- dbt-core 1.5+
- dbt-postgres

## Installation

```bash
cd elementary-data
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Usage

### Start Infrastructure

```bash
make up
# or
docker-compose up -d
```

### Initialize dbt

```bash
make deps
# or
cd dbt_project && dbt deps
```

### Load Seed Data

```bash
make seed
# or
cd dbt_project && dbt seed
```

### Run Models

```bash
make run
# or
cd dbt_project && dbt run
```

### Run Tests

```bash
make test
# or
cd dbt_project && dbt test
```

### Generate Elementary Report

```bash
make report
# or
edr report
```

### Full Pipeline

```bash
make pipeline
```

## Data Model

### Source Layer
- `raw_orders`: Order transactions
- `raw_customers`: Customer master data
- `raw_products`: Product catalog

### Staging Layer
- `stg_orders`: Cleaned and typed orders
- `stg_customers`: Cleaned customer data
- `stg_products`: Cleaned product data

### Marts Layer
- `fct_orders`: Order fact table with metrics
- `dim_customers`: Customer dimension with aggregations

## Elementary Features Demonstrated

### 1. Schema Tests
```yaml
- dbt_utils.unique_combination_of_columns
- accepted_values
- not_null
- relationships
```

### 2. Data Quality Tests
```yaml
- elementary.volume_anomalies
- elementary.freshness_anomalies
- elementary.column_anomalies
```

### 3. Monitoring Configuration
```yaml
elementary:
  timestamp_column: updated_at
  anomaly_sensitivity: 3
```

## Reports

Elementary generates HTML reports with:
- Test results dashboard
- Model execution history
- Data lineage visualization
- Anomaly detection results

Access reports at: `./dbt_project/edr_reports/`

## Alerting

Configure Slack alerts in `profiles.yml`:
```yaml
elementary:
  slack_token: xoxb-xxx
  slack_channel_name: data-alerts
```

## License

MIT
