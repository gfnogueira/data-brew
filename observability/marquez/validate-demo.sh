#!/bin/bash

# Validate Marquez demo setup
set -e

echo "Validating Marquez Demo Setup"
echo "============================="

success_count=0
total_tests=0

# Test function
test_item() {
    local name="$1"
    local command="$2"
    
    total_tests=$((total_tests + 1))
    printf "%-40s" "$name..."
    
    if eval "$command" > /dev/null 2>&1; then
        echo "OK"
        success_count=$((success_count + 1))
    else
        echo "FAIL"
    fi
}

echo ""
echo "1. INFRASTRUCTURE TESTS:"

# Test containers
if command -v podman > /dev/null 2>&1; then
    CONTAINER_CMD="podman"
else
    CONTAINER_CMD="docker"
fi

test_item "PostgreSQL container running" "$CONTAINER_CMD ps | grep marquez-db"
test_item "Marquez API container running" "$CONTAINER_CMD ps | grep marquez-api"  
test_item "Marquez Web container running" "$CONTAINER_CMD ps | grep marquez-web"

# Test connectivity
test_item "API responds on localhost" "curl -s -f http://localhost:5555/api/v1/namespaces"
test_item "Web UI loads" "curl -s -f http://localhost:3000"

echo ""
echo "2. DEMO DATA TESTS:"

# Test data
test_item "Default namespace exists" "curl -s http://localhost:5555/api/v1/namespaces | grep default"
test_item "Jobs loaded" "curl -s 'http://localhost:5555/api/v1/namespaces/default/jobs' | grep -q '\"totalCount\": [1-9]'"
test_item "Datasets created" "curl -s 'http://localhost:5555/api/v1/namespaces/default/datasets' | grep -q orders"
test_item "Extract job exists" "curl -s 'http://localhost:5555/api/v1/namespaces/default/jobs' | grep extract-orders"
test_item "Transform job exists" "curl -s 'http://localhost:5555/api/v1/namespaces/default/jobs' | grep transform-sales"
test_item "Load job exists" "curl -s 'http://localhost:5555/api/v1/namespaces/default/jobs' | grep load-warehouse"

echo ""
echo "3. LINEAGE TESTS:"

test_item "Jobs have inputs/outputs" "curl -s 'http://localhost:5555/api/v1/namespaces/default/jobs/extract-orders' | grep -q inputs"
test_item "Lineage connects jobs" "curl -s 'http://localhost:5555/api/v1/namespaces/default/jobs/transform-sales' | grep -q orders_clean"

echo ""
echo "VALIDATION RESULTS:"
echo "==================="

if [ $success_count -eq $total_tests ]; then
    echo "SUCCESS: Demo is ready ($success_count/$total_tests tests passed)"
    echo ""
    echo "Your Demo is ready!"
    echo ""
    echo "Next steps:"
    echo "1. Open http://localhost:3000"
    echo "2. Navigate: Jobs -> extract-orders -> Graph View"  
    echo "3. Practice your presentation timing"
    echo ""
    echo "Container Engine: $CONTAINER_CMD"
    
elif [ $success_count -gt $((total_tests * 3 / 4)) ]; then
    echo "WARNING: Demo mostly ready ($success_count/$total_tests tests passed)"
    echo "Some minor issues may need attention"
    
else
    echo "ERROR: Demo needs attention ($success_count/$total_tests tests passed)"
    echo "Run 'make restart' and './load-demo-data.sh'"
fi

echo ""
echo "Quick commands:"
echo "- Check status: make status"
echo "- View logs: make logs" 
echo "- Restart: make restart"
echo "- Load data: ./load-demo-data.sh"
