#!/bin/bash

# Apache Pinot PoC - Batch Ingestion Runner
# Executes batch ingestion job for historical data

set -e

echo "Starting batch ingestion job..."

# Check if batch data exists
if [ ! -d "batch-ingestion/data" ] || [ -z "$(ls -A batch-ingestion/data)" ]; then
    echo "No batch data found. Generating now..."
    python3 batch-ingestion/generate_batch_data.py
fi

# Run batch ingestion
echo "Executing batch ingestion..."
docker-compose exec -T pinot-controller bin/pinot-admin.sh LaunchDataIngestionJob \
  -jobSpecFile /batch-ingestion/job-spec.yaml

echo ""
echo "Batch ingestion completed!"
echo "Query offline table: SELECT COUNT(*) FROM events_OFFLINE"
echo "Query hybrid table: SELECT COUNT(*) FROM events"