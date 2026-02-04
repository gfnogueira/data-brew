# DuckDB Analytics

Local OLAP analytics solution using DuckDB and Parquet for high-performance analytical workloads.

## Overview

This project demonstrates how to leverage DuckDB as an embedded analytical database with Parquet files for efficient data storage and querying. The solution is designed for scenarios requiring fast analytical queries without the overhead of a traditional database server.

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Raw Data      │ --> │  Parquet Files   │ --> │    DuckDB       │
│   (CSV/JSON)    │     │  (Columnar)      │     │   (Analytics)   │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

## Features

- In-process OLAP database (no server required)
- Direct Parquet file querying
- SQL interface for complex analytics
- Memory-efficient columnar storage
- Data quality validation
- Aggregation and reporting pipelines

## Project Structure

```
duckdb-analytics/
├── data/
│   ├── raw/              # Source CSV files
│   └── processed/        # Parquet files
├── scripts/
│   ├── generate_data.py  # Synthetic data generation
│   ├── transform.py      # CSV to Parquet conversion
│   └── analytics.py      # Analytical queries
├── queries/
│   └── reports.sql       # SQL query templates
├── requirements.txt
├── Makefile
├── README.md
└── ESTUDO.md             # Documentation (PT-BR)
```

## Requirements

- Python 3.9+
- DuckDB 0.9+

## Installation

```bash
cd duckdb-analytics
python -m venv venv
source venv/bin/activate  # Linux/macOS
pip install -r requirements.txt
```

## Usage

### Generate Sample Data

```bash
make generate
# or
python scripts/generate_data.py
```

### Transform to Parquet

```bash
make transform
# or
python scripts/transform.py
```

### Run Analytics

```bash
make analytics
# or
python scripts/analytics.py
```

### Interactive Mode

```bash
make shell
# or
python scripts/shell.py
```

## Data Model

The dataset simulates a retail company with the following entities:

- **transactions**: Sales transactions with product, customer, and store information
- **products**: Product catalog with categories and pricing
- **customers**: Customer demographics and segments
- **stores**: Store locations and regions

## Sample Queries

Revenue by product category:
```sql
SELECT 
    p.category,
    SUM(t.quantity * t.unit_price) as total_revenue,
    COUNT(DISTINCT t.transaction_id) as transaction_count
FROM transactions t
JOIN products p ON t.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;
```

## Performance Considerations

- Parquet files provide 5-10x compression vs CSV
- DuckDB leverages vectorized execution for fast aggregations
- Memory usage is optimized through streaming and lazy evaluation

## Use Cases

1. **Ad-hoc Analytics**: Quick exploration of large datasets
2. **ETL Pipelines**: Data transformation and validation
3. **Embedded Analytics**: Integration with applications
4. **Data Validation**: Quality checks before loading to warehouse
