#!/bin/bash

echo "REAL-TIME FRAUD MONITOR - PODMAN VERSION"
echo "========================================"
echo ""
echo "Monitoring fraud stream from ksqlDB..."
echo "Press Ctrl+C to stop monitoring"
echo ""
echo "Format: [TIME] | TRANSACTION_ID | USER | AMOUNT | STATE | ALERT"
echo "================================================================"

# Check if ksqlDB is available
if ! curl -s http://localhost:8088/info > /dev/null; then
    echo "ERROR: ksqlDB is not available!"
    echo "Execute first: ./podman_start_demo.sh"
    exit 1
fi

# Monitor frauds in real-time
curl -X POST http://localhost:8088/query \
  -H "Content-Type: application/vnd.ksql+json; charset=utf-8" \
  -d '{
    "ksql": "SELECT TIMESTAMPTOSTRING(ROWTIME, '\''HH:mm:ss'\'') as event_time, transaction_id, user_id, amount, state, alert_message FROM fraud_alerts EMIT CHANGES;",
    "streamsProperties": {}
  }' 2>/dev/null | while IFS= read -r line; do
    # Process only lines with transaction data
    if echo "$line" | grep -q '"row"'; then
        # Extract data using jq
        event_time=$(echo "$line" | jq -r '.row.columns[0]' 2>/dev/null)
        transaction_id=$(echo "$line" | jq -r '.row.columns[1]' 2>/dev/null)
        user_id=$(echo "$line" | jq -r '.row.columns[2]' 2>/dev/null)
        amount=$(echo "$line" | jq -r '.row.columns[3]' 2>/dev/null)
        state=$(echo "$line" | jq -r '.row.columns[4]' 2>/dev/null)
        alert_message=$(echo "$line" | jq -r '.row.columns[5]' 2>/dev/null)
        
        # Check if data is valid
        if [[ "$event_time" != "null" && "$transaction_id" != "null" ]]; then
            # Format monetary value
            if [[ "$amount" =~ ^[0-9]+\.?[0-9]*$ ]]; then
                formatted_amount="\$ $(printf "%.2f" "$amount")"
            else
                formatted_amount="\$ $amount"
            fi
            
            # Display formatted fraud alert
            echo "FRAUD [$event_time] | $transaction_id | $user_id | $formatted_amount | $state"
            echo "   └─ $alert_message"
            echo ""
        fi
    fi
done

echo ""
echo "Fraud monitor finished - Podman version"
