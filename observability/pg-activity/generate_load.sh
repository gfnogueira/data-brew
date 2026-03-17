#!/bin/bash
# Script to generate database load for monitoring demonstration

set -e

echo "Generating database load for monitoring..."
echo ""

# Check if PostgreSQL is running
if ! docker-compose ps postgres | grep -q "Up"; then
    echo "Error: PostgreSQL is not running"
    echo "Start with: docker-compose up -d"
    exit 1
fi

# Generate various types of queries to monitor
echo "Running sample queries to generate activity..."

docker-compose exec -T postgres psql -U postgres -d testdb <<EOF
-- Simple queries
SELECT COUNT(*) FROM users;
SELECT * FROM users WHERE username = 'alice';

-- Join queries
SELECT u.username, COUNT(o.id) as order_count 
FROM users u 
LEFT JOIN orders o ON u.id = o.user_id 
GROUP BY u.id, u.username;

-- Complex aggregation
SELECT 
    u.username,
    SUM(o.amount) as total_amount,
    COUNT(o.id) as order_count
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.status = 'completed'
GROUP BY u.id, u.username
HAVING SUM(o.amount) > 100
ORDER BY total_amount DESC;

-- Update operations
UPDATE orders SET status = 'processing' WHERE status = 'pending' LIMIT 1;

-- Insert operations
INSERT INTO orders (user_id, amount, status) 
VALUES (1, 99.99, 'pending');

-- Function call (generates multiple queries)
SELECT generate_activity();
EOF

echo ""
echo "Load generation complete!"
echo "Now run pg_activity to monitor: ./run_monitoring.sh"
echo ""
