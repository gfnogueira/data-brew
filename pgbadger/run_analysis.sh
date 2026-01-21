#!/bin/bash
# Script to run pgBadger analysis on PostgreSQL logs

set -e

echo "PostgreSQL Log Analyzer - pgBadger PoC"
echo "======================================"
echo ""

# Check if pgBadger is installed
if ! command -v pgbadger &> /dev/null; then
    echo "Error: pgBadger is not installed"
    echo ""
    echo "Install with:"
    echo "  macOS:   brew install pgbadger"
    echo "  Ubuntu:  sudo apt-get install pgbadger"
    echo "  Or build from source: https://github.com/darold/pgbadger"
    exit 1
fi

# Check if logs directory exists
if [ ! -d "logs" ]; then
    echo "Error: logs directory not found"
    echo "Make sure PostgreSQL is running and generating logs"
    echo "Start with: docker-compose up -d"
    exit 1
fi

# Check if there are log files
LOG_COUNT=$(find logs -name "postgresql-*.log" 2>/dev/null | wc -l | tr -d ' ')

if [ "$LOG_COUNT" -eq 0 ]; then
    echo "No log files found in logs/ directory"
    echo ""
    echo "To generate logs:"
    echo "1. Start PostgreSQL: docker-compose up -d"
    echo "2. Generate some activity: docker-compose exec postgres psql -U postgres -d testdb -f /docker-entrypoint-initdb.d/init.sql"
    echo "3. Wait a few seconds for logs to be written"
    echo "4. Run this script again"
    exit 1
fi

echo "Found $LOG_COUNT log file(s)"
echo ""

# Create reports directory
mkdir -p reports

# Run pgBadger
echo "Running pgBadger analysis..."
echo ""

OUTPUT_FILE="reports/report-$(date +%Y%m%d-%H%M%S).html"

pgbadger \
    --prefix '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ' \
    --outfile "$OUTPUT_FILE" \
    --sample 100 \
    logs/postgresql-*.log

if [ $? -eq 0 ]; then
    echo ""
    echo "Success! Report generated: $OUTPUT_FILE"
    echo ""
    echo "Open the report in your browser:"
    echo "  open $OUTPUT_FILE"
    echo ""
    echo "Or view it at: file://$(pwd)/$OUTPUT_FILE"
else
    echo ""
    echo "Error: pgBadger analysis failed"
    exit 1
fi
