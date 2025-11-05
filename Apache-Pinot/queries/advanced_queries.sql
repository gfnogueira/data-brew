-- Apache Pinot PoC 
-- Queries leveraging star-tree indexes and advanced aggregations

-- 1. Star-Tree Optimized Query (Multi-Dimensional Aggregation)
SELECT 
    event_type,
    country,
    category,
    platform,
    COUNT(*) as event_count,
    SUM(amount) as total_revenue,
    SUM(quantity) as total_quantity,
    MAX(amount) as max_transaction
FROM events
WHERE event_time > ago('PT24H')
GROUP BY event_type, country, category, platform
ORDER BY total_revenue DESC
LIMIT 100;

-- 2. Percentile Analysis
SELECT 
    category,
    PERCENTILE50(amount) as median_amount,
    PERCENTILE75(amount) as p75_amount,
    PERCENTILE90(amount) as p90_amount,
    PERCENTILE95(amount) as p95_amount,
    PERCENTILE99(amount) as p99_amount
FROM events
WHERE event_type = 'purchase'
    AND event_time > ago('PT7D')
GROUP BY category
ORDER BY median_amount DESC;

-- 3. Moving Average (Time-Series)
SELECT 
    ToDateTime(event_time, 'yyyy-MM-dd HH:00') as hour_bucket,
    COUNT(*) as hourly_events,
    SUM(amount) as hourly_revenue,
    AVG(COUNT(*)) OVER (
        ORDER BY ToDateTime(event_time, 'yyyy-MM-dd HH:00')
        ROWS BETWEEN 23 PRECEDING AND CURRENT ROW
    ) as moving_avg_24h
FROM events
WHERE event_time > ago('PT7D')
GROUP BY hour_bucket
ORDER BY hour_bucket DESC
LIMIT 168;

-- 4. Retention Cohort Analysis
SELECT 
    ToDateTime(first_seen, 'yyyy-MM-dd') as cohort_date,
    COUNT(DISTINCT user_id) as cohort_size,
    COUNT(DISTINCT CASE WHEN days_since_first >= 1 THEN user_id END) as day_1_retained,
    COUNT(DISTINCT CASE WHEN days_since_first >= 7 THEN user_id END) as day_7_retained,
    COUNT(DISTINCT CASE WHEN days_since_first >= 30 THEN user_id END) as day_30_retained,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN days_since_first >= 7 THEN user_id END) / 
          NULLIF(COUNT(DISTINCT user_id), 0), 2) as retention_rate_7d
FROM (
    SELECT 
        user_id,
        MIN(event_time) as first_seen,
        event_time,
        DATEDIFF('day', MIN(event_time), event_time) as days_since_first
    FROM events
    WHERE event_time > ago('PT60D')
    GROUP BY user_id, event_time
)
GROUP BY cohort_date
ORDER BY cohort_date DESC
LIMIT 30;

-- 5. Advanced Funnel with Conversion Time
SELECT 
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) as step_1_page_view,
    COUNT(DISTINCT CASE WHEN event_type = 'product_view' THEN user_id END) as step_2_product_view,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) as step_3_add_cart,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) as step_4_purchase,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN event_type = 'product_view' THEN user_id END) / 
          NULLIF(COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END), 0), 2) as conv_1_to_2,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) / 
          NULLIF(COUNT(DISTINCT CASE WHEN event_type = 'product_view' THEN user_id END), 0), 2) as conv_2_to_3,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) / 
          NULLIF(COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END), 0), 2) as conv_3_to_4
FROM events
WHERE event_time > ago('PT24H')
LIMIT 1;

-- 6. Distinct Count Aggregation (HyperLogLog)
SELECT 
    ToDateTime(event_time, 'yyyy-MM-dd') as date,
    DISTINCTCOUNT(user_id) as unique_users,
    DISTINCTCOUNT(session_id) as unique_sessions,
    DISTINCTCOUNT(product_id) as unique_products_viewed,
    ROUND(COUNT(*) * 1.0 / DISTINCTCOUNT(session_id), 2) as avg_events_per_session
FROM events
WHERE event_time > ago('PT30D')
GROUP BY date
ORDER BY date DESC
LIMIT 30;

-- 7. Top N with Others Aggregation
SELECT 
    CASE 
        WHEN row_num <= 10 THEN product_id
        ELSE 'Others'
    END as product_group,
    SUM(purchase_count) as total_purchases,
    SUM(revenue) as total_revenue
FROM (
    SELECT 
        product_id,
        COUNT(*) as purchase_count,
        SUM(amount) as revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(amount) DESC) as row_num
    FROM events
    WHERE event_type = 'purchase'
        AND event_time > ago('PT7D')
    GROUP BY product_id
)
GROUP BY product_group
ORDER BY total_revenue DESC;

-- 8. Multi-Metric Dashboard Query (Optimized with Star-Tree)
SELECT 
    event_type,
    platform,
    COUNT(*) as total_events,
    DISTINCTCOUNT(user_id) as unique_users,
    SUM(amount) as total_revenue,
    AVG(amount) as avg_transaction,
    SUM(quantity) as total_units,
    AVG(duration_seconds) as avg_engagement_time,
    PERCENTILE90(amount) as p90_amount
FROM events
WHERE event_time > ago('PT1H')
GROUP BY event_type, platform
ORDER BY total_revenue DESC;

-- 9. Geographic Heatmap Data
SELECT 
    country,
    city,
    COUNT(*) as event_count,
    DISTINCTCOUNT(user_id) as unique_users,
    SUM(CASE WHEN event_type = 'purchase' THEN amount ELSE 0 END) as revenue,
    ROUND(AVG(CASE WHEN event_type = 'purchase' THEN amount END), 2) as avg_order_value,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) as purchasing_users
FROM events
WHERE event_time > ago('PT24H')
GROUP BY country, city
HAVING event_count > 10
ORDER BY revenue DESC
LIMIT 100;

-- 10. Session Duration and Engagement Metrics
SELECT 
    session_id,
    MIN(event_time) as session_start,
    MAX(event_time) as session_end,
    DATEDIFF('second', MIN(event_time), MAX(event_time)) as session_duration_sec,
    COUNT(*) as events_in_session,
    COUNT(DISTINCT event_type) as unique_event_types,
    COUNT(DISTINCT product_id) as products_viewed,
    SUM(CASE WHEN event_type = 'purchase' THEN amount ELSE 0 END) as session_revenue,
    CASE 
        WHEN SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) > 0 THEN 'Converted'
        ELSE 'Not Converted'
    END as conversion_status
FROM events
WHERE event_time > ago('PT6H')
GROUP BY session_id
HAVING COUNT(*) >= 3
ORDER BY session_revenue DESC
LIMIT 50;

-- 11. Real-Time Anomaly Detection Query
WITH recent_metrics AS (
    SELECT 
        ToDateTime(event_time, 'yyyy-MM-dd HH:mm') as time_bucket,
        COUNT(*) as event_count,
        SUM(amount) as revenue
    FROM events
    WHERE event_time > ago('PT2H')
    GROUP BY time_bucket
),
stats AS (
    SELECT 
        AVG(event_count) as avg_events,
        STDDEV(event_count) as stddev_events,
        AVG(revenue) as avg_revenue,
        STDDEV(revenue) as stddev_revenue
    FROM recent_metrics
)
SELECT 
    rm.time_bucket,
    rm.event_count,
    rm.revenue,
    CASE 
        WHEN rm.event_count > (s.avg_events + 2 * s.stddev_events) THEN 'High Traffic Alert'
        WHEN rm.event_count < (s.avg_events - 2 * s.stddev_events) THEN 'Low Traffic Alert'
        ELSE 'Normal'
    END as traffic_status,
    CASE 
        WHEN rm.revenue > (s.avg_revenue + 2 * s.stddev_revenue) THEN 'High Revenue Alert'
        WHEN rm.revenue < (s.avg_revenue - 2 * s.stddev_revenue) THEN 'Low Revenue Alert'
        ELSE 'Normal'
    END as revenue_status
FROM recent_metrics rm
CROSS JOIN stats s
ORDER BY rm.time_bucket DESC
LIMIT 120;

-- 12. Cross-Platform Comparison
SELECT 
    platform,
    device_type,
    COUNT(*) as total_events,
    DISTINCTCOUNT(user_id) as unique_users,
    COUNT(*) * 1.0 / DISTINCTCOUNT(user_id) as events_per_user,
    SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) as purchases,
    SUM(CASE WHEN event_type = 'purchase' THEN amount ELSE 0 END) as revenue,
    ROUND(100.0 * SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) / 
          NULLIF(COUNT(*), 0), 2) as purchase_rate,
    AVG(duration_seconds) as avg_engagement_sec
FROM events
WHERE event_time > ago('PT24H')
GROUP BY platform, device_type
ORDER BY revenue DESC;