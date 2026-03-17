-- Data Quality and Monitoring Scripts
-- Validation queries and monitoring views for production readiness

-- View: Data Freshness Check
CREATE OR REPLACE VIEW public.data_freshness_check AS
SELECT
    'ecommerce.sales' as table_name,
    COUNT(*) as total_records,
    MAX(sale_date) as last_update,
    EXTRACT(HOUR FROM (CURRENT_TIMESTAMP - MAX(sale_date))) as hours_since_last_update,
    CASE 
        WHEN EXTRACT(HOUR FROM (CURRENT_TIMESTAMP - MAX(sale_date))) < 1 THEN 'FRESH'
        WHEN EXTRACT(HOUR FROM (CURRENT_TIMESTAMP - MAX(sale_date))) < 24 THEN 'STALE'
        ELSE 'EXPIRED'
    END as freshness_status
FROM ecommerce.sales
UNION ALL
SELECT
    'ecommerce.products' as table_name,
    COUNT(*) as total_records,
    MAX(created_at) as last_update,
    EXTRACT(HOUR FROM (CURRENT_TIMESTAMP - MAX(created_at))) as hours_since_last_update,
    CASE 
        WHEN MAX(created_at) IS NULL THEN 'UNKNOWN'
        WHEN EXTRACT(HOUR FROM (CURRENT_TIMESTAMP - MAX(created_at))) < 1 THEN 'FRESH'
        ELSE 'STALE'
    END as freshness_status
FROM ecommerce.products;

-- View: Data Quality Scorecard
CREATE OR REPLACE VIEW public.data_quality_scorecard AS
WITH quality_checks AS (
    SELECT
        'products' as table_name,
        COUNT(*) as total_records,
        COUNT(*) FILTER (WHERE price IS NOT NULL) as non_null_price,
        COUNT(*) FILTER (WHERE price > 0) as valid_price,
        COUNT(*) FILTER (WHERE cost IS NOT NULL) as non_null_cost,
        COUNT(*) FILTER (WHERE cost > 0 AND cost < price) as valid_cost,
        COUNT(*) FILTER (WHERE category IS NOT NULL) as non_null_category
    FROM ecommerce.products
    UNION ALL
    SELECT
        'customers' as table_name,
        COUNT(*) as total_records,
        COUNT(*) FILTER (WHERE first_name IS NOT NULL) as non_null_price,
        COUNT(*) FILTER (WHERE email IS NOT NULL) as valid_price,
        COUNT(*) FILTER (WHERE state IS NOT NULL) as non_null_cost,
        COUNT(*) FILTER (WHERE customer_segment IS NOT NULL) as valid_cost,
        COUNT(*) FILTER (WHERE registration_date IS NOT NULL) as non_null_category
    FROM ecommerce.customers
    UNION ALL
    SELECT
        'sales' as table_name,
        COUNT(*) as total_records,
        COUNT(*) FILTER (WHERE customer_id IS NOT NULL) as non_null_price,
        COUNT(*) FILTER (WHERE product_id IS NOT NULL) as valid_price,
        COUNT(*) FILTER (WHERE total_amount IS NOT NULL) as non_null_cost,
        COUNT(*) FILTER (WHERE total_amount > 0) as valid_cost,
        COUNT(*) FILTER (WHERE sale_date IS NOT NULL) as non_null_category
    FROM ecommerce.sales
)
SELECT
    table_name,
    total_records,
    ROUND(100.0 * non_null_price / NULLIF(total_records, 0), 2) as completeness_pct,
    ROUND(100.0 * valid_price / NULLIF(total_records, 0), 2) as validity_pct,
    ROUND(100.0 * (non_null_price + valid_price + non_null_cost + valid_cost + non_null_category) / (5.0 * NULLIF(total_records, 0)), 2) as overall_quality_pct
FROM quality_checks
ORDER BY overall_quality_pct DESC;

-- View: Transaction Volume Trends
CREATE OR REPLACE VIEW public.transaction_volume_trends AS
SELECT
    DATE(sale_date) as sale_day,
    COUNT(*) as daily_transactions,
    SUM(total_amount) as daily_revenue,
    AVG(total_amount) as avg_transaction_value,
    COUNT(DISTINCT customer_id) as unique_daily_customers,
    COUNT(DISTINCT payment_method) as payment_methods_used,
    COUNT(DISTINCT store_location) as store_locations_active
FROM ecommerce.sales
GROUP BY DATE(sale_date)
ORDER BY sale_day DESC;

-- View: Customer Behavior Analysis
CREATE OR REPLACE VIEW public.customer_behavior_segments AS
WITH customer_stats AS (
    SELECT
        c.customer_id,
        c.customer_segment,
        COUNT(s.sale_id) as purchase_frequency,
        SUM(s.total_amount) as total_spent,
        AVG(s.total_amount) as avg_order_value,
        MAX(s.sale_date) as last_purchase,
        MIN(s.sale_date) as first_purchase,
        EXTRACT(DAY FROM (MAX(s.sale_date) - MIN(s.sale_date))) as days_active
    FROM ecommerce.customers c
    LEFT JOIN ecommerce.sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.customer_segment
)
SELECT
    customer_segment,
    COUNT(*) as segment_size,
    ROUND(AVG(purchase_frequency), 2) as avg_purchases_per_customer,
    ROUND(AVG(total_spent), 2) as avg_lifetime_value,
    ROUND(AVG(avg_order_value), 2) as avg_order_size,
    COUNT(*) FILTER (WHERE last_purchase > CURRENT_DATE - INTERVAL '30 days') as active_last_30_days,
    COUNT(*) FILTER (WHERE last_purchase > CURRENT_DATE - INTERVAL '90 days') as active_last_90_days
FROM customer_stats
GROUP BY customer_segment
ORDER BY avg_lifetime_value DESC;

-- View: Anomaly Detection Flags
CREATE OR REPLACE VIEW public.anomaly_detection_flags AS
SELECT
    DATE(sale_date) as sale_date,
    COUNT(*) as daily_sales,
    SUM(total_amount) as daily_revenue,
    AVG(total_amount) as avg_order_value,
    STDDEV(total_amount) as revenue_stddev,
    CASE 
        WHEN COUNT(*) > (SELECT AVG(daily_count) * 2 FROM (SELECT COUNT(*) as daily_count FROM ecommerce.sales GROUP BY DATE(sale_date)) sub) THEN 'HIGH_VOLUME_ALERT'
        WHEN AVG(total_amount) > (SELECT AVG(avg_value) * 1.5 FROM (SELECT AVG(total_amount) as avg_value FROM ecommerce.sales GROUP BY DATE(sale_date)) sub) THEN 'HIGH_AOV_ALERT'
        WHEN COUNT(*) < (SELECT AVG(daily_count) * 0.5 FROM (SELECT COUNT(*) as daily_count FROM ecommerce.sales GROUP BY DATE(sale_date)) sub) THEN 'LOW_VOLUME_ALERT'
        ELSE 'NORMAL'
    END as anomaly_flag
FROM ecommerce.sales
GROUP BY DATE(sale_date)
ORDER BY sale_date DESC;