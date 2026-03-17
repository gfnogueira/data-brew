#!/bin/bash

# Load demo data into Marquez
set -e

MARQUEZ_URL="http://localhost:5555/api/v1/lineage"

echo "Loading demo data into Marquez..."

# Check if Marquez is running
if ! curl -s -f "http://localhost:5555/api/v1/namespaces" > /dev/null; then
    echo "ERROR: Marquez is not accessible at localhost:5555"
    echo "Run 'make start' first and wait for services to be ready"
    exit 1
fi

echo "Marquez API is ready"

# Send OpenLineage events
counter=0
total=$(cat demo-data.json | jq length)

echo "Sending $total OpenLineage events..."

cat demo-data.json | jq -c '.[]' | while read -r event; do
    counter=$((counter + 1))
    
    printf "Sending event %d/%d... " $counter $total
    
    response=$(curl -X POST \
        -H "Content-Type: application/json" \
        -d "$event" \
        "$MARQUEZ_URL" \
        --silent --write-out "%{http_code}" --output /dev/null)
    
    if [ "$response" = "201" ] || [ "$response" = "200" ]; then
        echo "OK"
    else
        echo "ERROR (HTTP $response)"
    fi
    
    sleep 0.1
done

echo ""
echo "Demo data loaded successfully!"
echo "Access the UI at: http://localhost:3000"
echo ""
echo "You should now see:"
echo "- Jobs: extract-orders, transform-sales, load-warehouse"
echo "- Datasets: raw_orders, orders_clean, products_ref, sales_summary, warehouse_sales"
echo "- Visual lineage in Graph View"
