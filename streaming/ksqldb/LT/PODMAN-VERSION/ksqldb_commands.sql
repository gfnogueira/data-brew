-- KSQLDB COMMANDS FOR LIGHTNING TALK (5 MINUTES)
-- =================================================

-- 1. CHECK AVAILABLE KAFKA TOPICS
SHOW TOPICS;

-- 2. CREATE MAIN STREAM FROM KAFKA TOPIC
CREATE STREAM ecommerce_stream (
    transaction_id STRING,
    user_id STRING,
    product_name STRING,
    category STRING,
    amount DOUBLE,
    state STRING,
    timestamp STRING,
    payment_method STRING,
    device_type STRING,
    ip_address STRING,
    suspicious BOOLEAN,
    alert_message STRING
) WITH (
    KAFKA_TOPIC = 'ecommerce_transactions',
    VALUE_FORMAT = 'JSON'
);

-- 3. VERIFY CREATED STREAMS
SHOW STREAMS;

-- 4. VIEW REAL-TIME DATA
SELECT * FROM ecommerce_stream EMIT CHANGES LIMIT 10;

-- 5. CREATE FRAUD DETECTION STREAM
CREATE STREAM fraud_alerts AS
SELECT 
    transaction_id,
    user_id,
    product_name,
    amount,
    state,
    ip_address,
    alert_message,
    timestamp
FROM ecommerce_stream
WHERE suspicious = true
EMIT CHANGES;

-- 6. MONITOR FRAUDS IN REAL-TIME
SELECT * FROM fraud_alerts EMIT CHANGES;

-- 7. CREATE AGGREGATED TABLE - TRANSACTIONS BY STATE
CREATE TABLE sales_by_state AS
SELECT 
    state,
    COUNT(*) as transaction_count,
    SUM(amount) as total_sales,
    AVG(amount) as avg_amount
FROM ecommerce_stream
WINDOW TUMBLING (SIZE 1 MINUTE)
GROUP BY state
EMIT CHANGES;

-- 8. QUERY AGGREGATED TABLE (WAIT 10-15 SECONDS AFTER CREATION)
-- NOTE: Shows TEMPORAL WINDOWS (WINDOWSTART/WINDOWEND)
SELECT * FROM sales_by_state;

-- 9. FRAUD STATISTICS BY STATE
CREATE TABLE fraud_stats_by_state AS
SELECT 
    state,
    COUNT(*) as fraud_count,
    SUM(amount) as fraud_amount,
    AVG(amount) as avg_fraud_amount
FROM fraud_alerts
WINDOW TUMBLING (SIZE 2 MINUTES)
GROUP BY state
EMIT CHANGES;

-- 10. VIEW FRAUD STATISTICS (WAIT 10-15 SECONDS)
SELECT * FROM fraud_stats_by_state;
-- If error occurs, use: SELECT * FROM fraud_stats_by_state EMIT CHANGES;

-- QUICK COMMANDS FOR DEMO
-- =======================
-- 1. SHOW TOPICS;
-- 2. SELECT * FROM ecommerce_stream EMIT CHANGES LIMIT 5;
-- 3. SELECT * FROM fraud_alerts EMIT CHANGES;
-- 4. SELECT * FROM sales_by_state;

-- ADVANCED QUERIES FOR DEMONSTRATION
-- ===================================

-- High-value transactions
SELECT transaction_id, user_id, product_name, amount, state 
FROM ecommerce_stream 
WHERE amount > 1000 
EMIT CHANGES;

-- Transactions by payment method
SELECT payment_method, COUNT(*) as count, AVG(amount) as avg_amount
FROM ecommerce_stream 
WINDOW TUMBLING (SIZE 1 MINUTE)
GROUP BY payment_method 
EMIT CHANGES;

-- Device type analysis
SELECT device_type, COUNT(*) as transactions, SUM(amount) as total_value
FROM ecommerce_stream 
WINDOW TUMBLING (SIZE 2 MINUTES)
GROUP BY device_type 
EMIT CHANGES;

-- Real-time statistics
SELECT 
    COUNT(*) as total_transactions,
    AVG(amount) as avg_amount,
    MAX(amount) as max_amount,
    MIN(amount) as min_amount
FROM ecommerce_stream 
WINDOW TUMBLING (SIZE 1 MINUTE)
GROUP BY 1
EMIT CHANGES;
