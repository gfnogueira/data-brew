#!/bin/bash

# Complete setup script for Marquez Demo
set -e

echo "Marquez Demo - Complete Setup"
echo "==========================================="

# Detect container engine
if command -v podman > /dev/null 2>&1; then
    CONTAINER_ENGINE="podman"
    COMPOSE_CMD="podman-compose"
else
    CONTAINER_ENGINE="docker" 
    COMPOSE_CMD="docker-compose"
fi

echo "Using container engine: $CONTAINER_ENGINE"

# Check if compose is available
if ! command -v $COMPOSE_CMD > /dev/null 2>&1; then
    echo "WARNING: $COMPOSE_CMD not found"
    if [ "$CONTAINER_ENGINE" = "podman" ]; then
        echo "Install with: pip install podman-compose"
        echo "Or use docker-compose with podman backend"
        COMPOSE_CMD="docker-compose"
    fi
fi

echo ""
echo "Step 1: Starting services..."
make start

echo ""
echo "Step 2: Waiting for services to be ready..."
echo "This may take 2-3 minutes for first-time setup..."

# Wait for services with timeout
timeout=180
counter=0
while [ $counter -lt $timeout ]; do
    if curl -s -f http://localhost:5555/api/v1/namespaces > /dev/null 2>&1; then
        echo "Services are ready!"
        break
    fi
    
    printf "."
    sleep 5
    counter=$((counter + 5))
    
    if [ $counter -ge $timeout ]; then
        echo ""
        echo "Timeout waiting for services. Checking status..."
        make status
        exit 1
    fi
done

echo ""
echo "Step 3: Loading demo data..."
./load-demo-data.sh

echo ""
echo "Step 4: Validating setup..."
./validate-demo.sh

echo ""
echo "========================================="
echo "DEMO SETUP COMPLETE!"
echo "========================================="
echo ""
echo "Your Lightning Talk is ready:"
echo "1. Open: http://localhost:3000"
echo "2. Navigate: Jobs -> extract-orders -> Graph View"
echo "3. Practice timing: 5 minutes total"
echo ""
echo "Container Engine: $CONTAINER_ENGINE"
echo "Presentation Guide: PRESENTATION-GUIDE.md"
echo ""
echo "Quick commands:"
echo "  make status    - Check service health"
echo "  make logs      - View service logs"
echo "  make restart   - Restart if needed"
echo ""
echo "Break a leg with your presentation!"
