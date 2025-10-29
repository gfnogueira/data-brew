-- Apache Pinot PoC - Analytics Query Patterns
-- Querie real-time analytics capabilities

-- 1. Total Events Count
SELECT COUNT(*) as total_events
FROM events
LIMIT 1;

-- 2. Events by Type (Last Hour)
SELECT 
    event_type,
    COUNT(*) as event_count,
    ROUND(AVG(duration_seconds), 2) as avg_duration
FROM events
WHERE event_time > ago('PT1H')
GROUP BY event_type
ORDER BY event_count DESC
LIMIT 10;

-- 3. Revenue by Category (Real-Time)
SELECT 
    category,
    COUNT(*) as purchases,
    SUM(amount) as total_revenue,
    ROUND(AVG(amount), 2) as avg_order_value,
    SUM(quantity) as total_units
FROM events
WHERE event_type = 'purchase'
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;

-- 4. Top Countries by Activity (Last 5 Minutes)
SELECT 
    country,
    COUNT(*) as event_count,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT session_id) as sessions
FROM events
WHERE event_time > ago('PT5M')
GROUP BY country
ORDER BY event_count DESC
LIMIT 10;

-- 5. Platform Performance
SELECT 
    platform,
    device_type,
    COUNT(*) as events,
    COUNT(DISTINCT user_id) as users,
    ROUND(AVG(duration_seconds), 2) as avg_engagement_sec
FROM events
WHERE event_time > ago('PT1H')
GROUP BY platform, device_type
ORDER BY events DESC;

-- 6. Time-Series Events (Per Minute)
SELECT 
    ToDateTime(event_time, 'yyyy-MM-dd HH:mm') as time_bucket,
    COUNT(*) as events_per_minute,
    COUNT(DISTINCT user_id) as unique_users
FROM events
WHERE event_time > ago('PT1H')
GROUP BY ToDateTime(event_time, 'yyyy-MM-dd HH:mm')
ORDER BY time_bucket DESC
LIMIT 60;

-- 7. User Funnel Analysis
SELECT 
    event_type,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(*) as total_events,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM events
WHERE event_type IN ('page_view', 'product_view', 'add_to_cart', 'purchase')
    AND event_time > ago('PT24H')
GROUP BY event_type
ORDER BY 
    CASE event_type
        WHEN 'page_view' THEN 1
        WHEN 'product_view' THEN 2
        WHEN 'add_to_cart' THEN 3
        WHEN 'purchase' THEN 4
    END;

-- 8. High-Value Transactions (Last Hour)
SELECT 
    event_id,
    user_id,
    category,
    amount,
    quantity,
    country,
    city,
    ToDateTime(event_time, 'yyyy-MM-dd HH:mm:ss') as purchase_time
FROM events
WHERE event_type = 'purchase'
    AND amount > 200
    AND event_time > ago('PT1H')
ORDER BY amount DESC
LIMIT 20;

-- 9. Geographic Revenue Distribution
SELECT 
    country,
    city,
    COUNT(*) as purchases,
    SUM(amount) as revenue,
    ROUND(AVG(amount), 2) as avg_transaction,
    COUNT(DISTINCT user_id) as customers
FROM events
WHERE event_type = 'purchase'
    AND event_time > ago('PT24H')
GROUP BY country, city
ORDER BY revenue DESC
LIMIT 20;

-- 10. Session Analysis
SELECT 
    session_id,
    MIN(event_time) as session_start,
    MAX(event_time) as session_end,
    COUNT(*) as events_in_session,
    COUNT(DISTINCT event_type) as event_types,
    SUM(CASE WHEN event_type = 'purchase' THEN amount ELSE 0 END) as session_revenue
FROM events
WHERE event_time > ago('PT2H')
GROUP BY session_id
HAVING COUNT(*) > 5
ORDER BY session_revenue DESC
LIMIT 20;

-- 11. Product Performance
SELECT 
    product_id,
    COUNT(DISTINCT CASE WHEN event_type = 'product_view' THEN user_id END) as views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) as add_to_carts,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) as purchases,
    ROUND(
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT CASE WHEN event_type = 'product_view' THEN user_id END), 0),
        2
    ) as conversion_rate
FROM events
WHERE event_time > ago('PT24H')
GROUP BY product_id
ORDER BY purchases DESC
LIMIT 20;

-- 12. Real-Time Dashboard Metrics (Last 5 Minutes)
SELECT 
    COUNT(*) as total_events,
    COUNT(DISTINCT user_id) as active_users,
    COUNT(DISTINCT session_id) as active_sessions,
    SUM(CASE WHEN event_type = 'purchase' THEN amount ELSE 0 END) as revenue_5min,
    SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) as transactions_5min,
    ROUND(AVG(CASE WHEN event_type = 'purchase' THEN amount END), 2) as avg_transaction_value
FROM events
WHERE event_time > ago('PT5M')
LIMIT 1;