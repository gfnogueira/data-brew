#!/bin/bash
# Elementary Data Pipeline Execution Script

set -e

DBT_DIR="dbt_project"

echo "=========================================="
echo "Elementary Data Pipeline"
echo "=========================================="

# Check if PostgreSQL is running
echo "Checking database connection..."
if ! docker-compose ps | grep -q "Up"; then
    echo "Starting PostgreSQL..."
    docker-compose up -d
    sleep 5
fi

cd "$DBT_DIR"

# Install dependencies if not present
if [ ! -d "dbt_packages" ]; then
    echo "Installing dbt packages..."
    dbt deps
fi

echo ""
echo "Step 1: Loading seed data..."
dbt seed

echo ""
echo "Step 2: Running models..."
dbt run

echo ""
echo "Step 3: Running tests..."
dbt test || true

echo ""
echo "Step 4: Generating Elementary report..."
edr report

echo ""
echo "=========================================="
echo "Pipeline completed"
echo "Report available at: dbt_project/edr_reports/"
echo "=========================================="
