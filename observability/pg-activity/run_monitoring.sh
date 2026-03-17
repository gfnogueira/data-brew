#!/bin/bash
# Script to run pg_activity monitoring

set -e

echo "PostgreSQL Real-Time Monitoring - pg_activity PoC"
echo "================================================="
echo ""

# Check if pg_activity is installed
if ! command -v pg_activity &> /dev/null; then
    echo "Error: pg_activity is not installed"
    echo ""
    echo "Install with:"
    echo "  macOS:   brew install pg-activity"
    echo "  Ubuntu:  sudo apt-get install pg-activity"
    echo "  Python:  pip install pg-activity"
    echo ""
    echo "Or from source: https://github.com/dalibo/pg_activity"
    exit 1
fi

# Check if PostgreSQL is running
if ! docker-compose ps postgres | grep -q "Up"; then
    echo "Starting PostgreSQL container..."
    docker-compose up -d
    echo "Waiting for PostgreSQL to be ready..."
    sleep 5
fi

# Check connection
if ! docker-compose exec -T postgres pg_isready -U postgres &> /dev/null; then
    echo "Error: Cannot connect to PostgreSQL"
    echo "Check if container is running: docker-compose ps"
    exit 1
fi

echo "PostgreSQL is running"
echo ""
echo "Starting pg_activity monitoring..."
echo ""
echo "Keyboard shortcuts:"
echo "  Space - Pause/Resume"
echo "  r     - Refresh now"
echo "  q     - Quit"
echo "  ?     - Show help"
echo ""
echo "Press Ctrl+C or 'q' to exit"
echo ""

# Run pg_activity
pg_activity \
    -h localhost \
    -p 5433 \
    -U postgres \
    -d testdb \
    --no-password \
    --refresh 2
