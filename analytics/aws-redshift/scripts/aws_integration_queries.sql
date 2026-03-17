-- ================================
-- AWS REDSHIFT INTEGRATION QUERIES
-- ================================

-- This file demonstrates Redshift's AWS ecosystem integration capabilities
-- showcasing features that highlight usability and integration power rather than raw performance

-- ================================
-- QUERY 1: MULTI-SERVICE DATA LAKE FEDERATION WITH REAL-TIME ANALYTICS
-- ================================

-- This query demonstrates Redshift Spectrum integration with S3 data lake,
-- combined with live IoT data streaming, ML predictions, and cross-service analytics

-- First, create external schema for S3 data lake integration
CREATE EXTERNAL SCHEMA IF NOT EXISTS s3_datalake
FROM DATA CATALOG
DATABASE 'ecommerce_datalake'
IAM_ROLE 'arn:aws:iam::xxxxxxxxxxxxx:role/RedshiftSpectrumRole'
REGION 'us-east-1';

-- Create external table for historical transaction data in S3 (Parquet format)
CREATE EXTERNAL TABLE IF NOT EXISTS s3_datalake.historical_transactions (
    transaction_id BIGINT,
    customer_id INT,
    product_id INT,
    transaction_date DATE,
    amount DECIMAL(12,2),
    channel VARCHAR(20),
    location_lat DECIMAL(10,6),
    location_lng DECIMAL(10,6),
    device_fingerprint VARCHAR(100),
    session_duration INT,
    page_views INT,
    referrer_source VARCHAR(50),
    marketing_campaign VARCHAR(50)
)
STORED AS PARQUET
LOCATION 's3://datalake-bucket/historical-transactions/'
TABLE PROPERTIES ('compression_type'='snappy');

-- Create external table for real-time IoT sensor data from Kinesis/S3
CREATE EXTERNAL TABLE IF NOT EXISTS s3_datalake.store_sensors (
    sensor_id VARCHAR(50),
    store_id INT,
    timestamp_utc TIMESTAMP,
    foot_traffic_count INT,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    noise_level DECIMAL(5,2),
    wifi_connections INT,
    pos_terminal_activity INT,
    energy_consumption DECIMAL(8,2)
)
STORED AS PARQUET
LOCATION 's3://iot-bucket/store-sensors/'
TABLE PROPERTIES ('compression_type'='gzip');

-- Main complex query: Federated analytics combining multiple AWS services
WITH real_time_store_metrics AS (
    -- Real-time store environment analysis from IoT sensors
    SELECT 
        s.store_id,
        DATE_TRUNC('hour', s.timestamp_utc) as hour_bucket,
        AVG(s.foot_traffic_count) as avg_foot_traffic,
        AVG(s.temperature) as avg_temperature,
        AVG(s.humidity) as avg_humidity,
        AVG(s.wifi_connections) as avg_wifi_connections,
        SUM(s.pos_terminal_activity) as total_pos_activity,
        AVG(s.energy_consumption) as avg_energy_consumption,
        -- Calculate comfort index using multiple sensors
        CASE 
            WHEN AVG(s.temperature) BETWEEN 20 AND 24 
                 AND AVG(s.humidity) BETWEEN 40 AND 60 
                 AND AVG(s.noise_level) < 70 
            THEN 'Optimal'
            WHEN AVG(s.temperature) BETWEEN 18 AND 26 
                 AND AVG(s.humidity) BETWEEN 30 AND 70 
            THEN 'Good'
            ELSE 'Poor'
        END as store_comfort_level
    FROM s3_datalake.store_sensors s
    WHERE s.timestamp_utc >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
    GROUP BY s.store_id, DATE_TRUNC('hour', s.timestamp_utc)
),

historical_transaction_patterns AS (
    -- Historical transaction analysis from S3 data lake
    SELECT 
        ht.customer_id,
        ht.channel,
        DATE_TRUNC('month', ht.transaction_date) as month_bucket,
        COUNT(*) as transaction_count,
        SUM(ht.amount) as total_spent,
        AVG(ht.amount) as avg_transaction,
        AVG(ht.session_duration) as avg_session_duration,
        AVG(ht.page_views) as avg_page_views,
        -- Geographic clustering using geospatial functions
        ST_GeogPoint(ht.location_lng, ht.location_lat) as customer_location,
        -- Device behavior analysis
        COUNT(DISTINCT ht.device_fingerprint) as unique_devices,
        -- Marketing attribution analysis
        FIRST_VALUE(ht.marketing_campaign) OVER (
            PARTITION BY ht.customer_id 
            ORDER BY ht.transaction_date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) as first_touch_campaign,
        LAST_VALUE(ht.marketing_campaign) OVER (
            PARTITION BY ht.customer_id 
            ORDER BY ht.transaction_date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) as last_touch_campaign
    FROM s3_datalake.historical_transactions ht
    WHERE ht.transaction_date >= CURRENT_DATE - 365
    GROUP BY 
        ht.customer_id, ht.channel, DATE_TRUNC('month', ht.transaction_date),
        ht.location_lng, ht.location_lat
),

current_sales_analysis AS (
    -- Current Redshift warehouse data analysis
    SELECT 
        s.customer_id,
        s.sale_date,
        s.total_amount,
        c.customer_segment,
        c.city,
        c.state,
        p.category,
        p.subcategory,
        -- Advanced customer scoring using ML functions
        ML_PREDICT('customer_lifetime_value_model', 
                   s.customer_id, s.total_amount, c.customer_segment) as predicted_clv,
        -- Anomaly detection for fraud prevention
        ML_PREDICT('fraud_detection_model',
                   s.customer_id, s.total_amount, s.sale_date) as fraud_score,
        -- Time-based features for seasonality analysis
        EXTRACT(quarter FROM s.sale_date) as quarter,
        EXTRACT(dow FROM s.sale_date) as day_of_week,
        EXTRACT(hour FROM s.sale_timestamp) as hour_of_day
    FROM ecommerce.sales s
    JOIN ecommerce.customers c ON s.customer_id = c.customer_id
    JOIN ecommerce.products p ON s.product_id = p.product_id
    WHERE s.sale_date >= CURRENT_DATE - 90
),

geospatial_market_analysis AS (
    -- Advanced geospatial analysis combining multiple data sources
    SELECT 
        htp.customer_id,
        htp.month_bucket,
        -- Calculate geographic market penetration
        ST_DWithin(htp.customer_location, 
                   ST_GeogPoint(-74.0060, 40.7128), -- NYC coordinates
                   50000) as within_50km_nyc,
        ST_DWithin(htp.customer_location, 
                   ST_GeogPoint(-118.2437, 34.0522), -- LA coordinates
                   50000) as within_50km_la,
        -- Calculate distance to nearest competitor store
        (SELECT MIN(ST_Distance(htp.customer_location, 
                               ST_GeogPoint(comp.longitude, comp.latitude)))
         FROM competitor_store_locations comp) as distance_to_competitor,
        htp.total_spent,
        htp.avg_transaction,
        htp.first_touch_campaign,
        htp.last_touch_campaign
    FROM historical_transaction_patterns htp
)

-- Final integrated query combining all data sources
SELECT 
    -- Customer demographic and behavioral insights
    csa.customer_id,
    csa.customer_segment,
    csa.city,
    csa.state,
    csa.category as preferred_category,
    
    -- Real-time store environment correlation
    rsm.store_comfort_level,
    rsm.avg_foot_traffic,
    rsm.total_pos_activity,
    
    -- Historical pattern analysis
    htp.channel as preferred_channel,
    htp.transaction_count as historical_transactions,
    htp.avg_session_duration,
    
    -- Geospatial market insights
    gma.within_50km_nyc,
    gma.within_50km_la,
    gma.distance_to_competitor,
    
    -- ML-powered predictions and scoring
    AVG(csa.predicted_clv) as avg_predicted_clv,
    MAX(csa.fraud_score) as max_fraud_score,
    
    -- Advanced business metrics
    SUM(csa.total_amount) as recent_revenue,
    SUM(htp.total_spent) as historical_revenue,
    
    -- Campaign attribution analysis
    gma.first_touch_campaign,
    gma.last_touch_campaign,
    CASE 
        WHEN gma.first_touch_campaign = gma.last_touch_campaign 
        THEN 'Single Touch'
        ELSE 'Multi Touch'
    END as attribution_type,
    
    -- Environmental impact on sales correlation
    CORR(rsm.avg_foot_traffic, csa.total_amount) OVER (
        PARTITION BY csa.customer_segment
    ) as foot_traffic_sales_correlation,
    
    -- Seasonal and temporal analysis
    AVG(CASE WHEN csa.quarter = 4 THEN csa.total_amount END) as q4_avg_spending,
    AVG(CASE WHEN csa.day_of_week IN (6,0) THEN csa.total_amount END) as weekend_avg_spending,
    
    -- Geographic market penetration score
    CASE 
        WHEN gma.within_50km_nyc AND gma.within_50km_la THEN 'Bi-Coastal'
        WHEN gma.within_50km_nyc THEN 'East Coast'
        WHEN gma.within_50km_la THEN 'West Coast'
        ELSE 'Other Markets'
    END as market_classification

FROM current_sales_analysis csa
LEFT JOIN historical_transaction_patterns htp 
    ON csa.customer_id = htp.customer_id
LEFT JOIN geospatial_market_analysis gma 
    ON htp.customer_id = gma.customer_id 
    AND htp.month_bucket = gma.month_bucket
LEFT JOIN real_time_store_metrics rsm 
    ON DATE_TRUNC('hour', csa.sale_timestamp) = rsm.hour_bucket

WHERE csa.fraud_score < 0.7  -- Filter out high fraud risk transactions

GROUP BY 
    csa.customer_id, csa.customer_segment, csa.city, csa.state,
    csa.category, rsm.store_comfort_level, rsm.avg_foot_traffic,
    rsm.total_pos_activity, htp.channel, htp.transaction_count,
    htp.avg_session_duration, gma.within_50km_nyc, gma.within_50km_la,
    gma.distance_to_competitor, gma.first_touch_campaign, gma.last_touch_campaign

ORDER BY avg_predicted_clv DESC, recent_revenue DESC
LIMIT 1000;

-- ================================
-- QUERY 2: DATA PIPELINE WITH CROSS-SERVICE ORCHESTRATION
-- ================================

-- This query demonstrates Redshift's integration with AWS Data Pipeline, Lambda functions,
-- SNS notifications, and automated data quality monitoring with intelligent alerting

-- Create external function to invoke AWS Lambda for real-time data enrichment
CREATE OR REPLACE EXTERNAL FUNCTION enrich_customer_data(customer_id INT)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA 'arn:aws:lambda:us-east-1:xxxxxxxxxxxxx:function:customer-enrichment-function'
IAM_ROLE 'arn:aws:iam::xxxxxxxxxxxxx:role/RedshiftLambdaRole';

-- Create external function for real-time fraud scoring via SageMaker endpoint
CREATE OR REPLACE EXTERNAL FUNCTION calculate_fraud_score(
    customer_id INT, 
    transaction_amount DECIMAL(12,2), 
    transaction_hour INT,
    days_since_last_transaction INT
)
RETURNS DECIMAL(5,3)
STABLE
LAMBDA 'arn:aws:lambda:us-east-1:xxxxxxxxxxxxx:function:sagemaker-fraud-scoring'
IAM_ROLE 'arn:aws:iam::xxxxxxxxxxxxx:role/RedshiftMLRole';

-- Create external function to send alerts via SNS
CREATE OR REPLACE EXTERNAL FUNCTION send_business_alert(
    alert_type VARCHAR(50),
    message VARCHAR(1000),
    severity VARCHAR(20)
)
RETURNS VARCHAR(100)
VOLATILE
LAMBDA 'arn:aws:lambda:us-east-1:xxxxxxxxxxxxx:function:sns-alerting-function'
IAM_ROLE 'arn:aws:iam::xxxxxxxxxxxxx:role/RedshiftSNSRole';

-- Complex orchestrated analysis query with automated monitoring and alerting
WITH data_quality_checks AS (
    -- Comprehensive data quality assessment across all sources
    SELECT 
        'ecommerce.sales' as table_name,
        COUNT(*) as total_records,
        COUNT(*) - COUNT(customer_id) as null_customer_ids,
        COUNT(*) - COUNT(product_id) as null_product_ids,
        COUNT(CASE WHEN total_amount <= 0 THEN 1 END) as invalid_amounts,
        COUNT(CASE WHEN sale_date > CURRENT_DATE THEN 1 END) as future_dates,
        COUNT(CASE WHEN sale_date < '2020-01-01' THEN 1 END) as ancient_dates,
        -- Calculate data freshness
        DATEDIFF(hour, MAX(sale_timestamp), CURRENT_TIMESTAMP) as hours_since_last_update,
        -- Data distribution analysis
        STDDEV(total_amount) / AVG(total_amount) as amount_coefficient_variation,
        COUNT(DISTINCT customer_id) as unique_customers,
        COUNT(DISTINCT product_id) as unique_products
    FROM ecommerce.sales
    WHERE sale_date >= CURRENT_DATE - 7
    
    UNION ALL
    
    SELECT 
        'ecommerce.customers' as table_name,
        COUNT(*),
        COUNT(*) - COUNT(email) as null_emails,
        COUNT(*) - COUNT(customer_segment) as null_segments,
        COUNT(CASE WHEN email NOT LIKE '%@%' THEN 1 END) as invalid_emails,
        COUNT(CASE WHEN registration_date > CURRENT_DATE THEN 1 END) as future_registrations,
        COUNT(CASE WHEN registration_date < '2010-01-01' THEN 1 END) as very_old_registrations,
        NULL as hours_since_last_update,
        NULL as amount_coefficient_variation,
        COUNT(DISTINCT customer_segment) as unique_segments,
        NULL as unique_products
    FROM ecommerce.customers
),

advanced_customer_analysis AS (
    -- Real-time customer analysis with external enrichment
    SELECT 
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        c.city,
        c.state,
        c.lifetime_value,
        
        -- Real-time data enrichment via Lambda function
        enrich_customer_data(c.customer_id) as enriched_profile_json,
        
        -- Extract JSON data from enrichment function
        JSON_EXTRACT_PATH_TEXT(enrich_customer_data(c.customer_id), 'credit_score') as credit_score,
        JSON_EXTRACT_PATH_TEXT(enrich_customer_data(c.customer_id), 'social_media_score') as social_score,
        JSON_EXTRACT_PATH_TEXT(enrich_customer_data(c.customer_id), 'external_segment') as external_segment,
        JSON_EXTRACT_PATH_TEXT(enrich_customer_data(c.customer_id), 'risk_category') as risk_category,
        
        -- Transaction analysis
        COUNT(s.sale_id) as transaction_count_7d,
        SUM(s.total_amount) as revenue_7d,
        AVG(s.total_amount) as avg_transaction_7d,
        MAX(s.sale_timestamp) as last_transaction_timestamp,
        
        -- Behavioral pattern analysis
        COUNT(DISTINCT DATE(s.sale_timestamp)) as active_days_7d,
        COUNT(DISTINCT EXTRACT(hour FROM s.sale_timestamp)) as active_hours_7d,
        MODE() WITHIN GROUP (ORDER BY EXTRACT(hour FROM s.sale_timestamp)) as preferred_hour,
        
        -- Advanced fraud scoring with external ML model
        AVG(calculate_fraud_score(
            c.customer_id,
            s.total_amount,
            EXTRACT(hour FROM s.sale_timestamp),
            DATEDIFF(day, LAG(s.sale_date) OVER (PARTITION BY c.customer_id ORDER BY s.sale_date), s.sale_date)
        )) as avg_fraud_score,
        
        -- Customer value progression analysis
        (SUM(s.total_amount) - c.lifetime_value) as value_change_7d,
        CASE 
            WHEN (SUM(s.total_amount) - c.lifetime_value) / NULLIF(c.lifetime_value, 0) > 0.2 
            THEN 'Accelerating'
            WHEN (SUM(s.total_amount) - c.lifetime_value) / NULLIF(c.lifetime_value, 0) < -0.1 
            THEN 'Declining'
            ELSE 'Stable'
        END as value_trend
        
    FROM ecommerce.customers c
    LEFT JOIN ecommerce.sales s ON c.customer_id = s.customer_id 
        AND s.sale_date >= CURRENT_DATE - 7
    GROUP BY 
        c.customer_id, c.customer_name, c.customer_segment, 
        c.city, c.state, c.lifetime_value
),

business_intelligence_alerts AS (
    -- Automated business intelligence with alerting
    SELECT 
        alert_category,
        alert_message,
        alert_severity,
        affected_records,
        metric_value,
        threshold_value,
        -- Send real-time alerts via SNS
        send_business_alert(alert_category, alert_message, alert_severity) as alert_response
    FROM (
        -- Data quality alerts
        SELECT 
            'DATA_QUALITY' as alert_category,
            CASE 
                WHEN dqc.hours_since_last_update > 2 
                THEN 'Data freshness alert: ' || dqc.table_name || ' not updated in ' || dqc.hours_since_last_update || ' hours'
                WHEN (dqc.null_customer_ids * 100.0 / dqc.total_records) > 5
                THEN 'Data integrity alert: High null rate in customer_ids for ' || dqc.table_name
                WHEN dqc.invalid_amounts > 0
                THEN 'Data validation alert: Invalid amounts detected in ' || dqc.table_name
            END as alert_message,
            CASE 
                WHEN dqc.hours_since_last_update > 6 THEN 'CRITICAL'
                WHEN dqc.hours_since_last_update > 2 THEN 'HIGH'
                WHEN (dqc.null_customer_ids * 100.0 / dqc.total_records) > 10 THEN 'HIGH'
                ELSE 'MEDIUM'
            END as alert_severity,
            dqc.total_records as affected_records,
            COALESCE(dqc.hours_since_last_update, dqc.null_customer_ids) as metric_value,
            CASE 
                WHEN dqc.hours_since_last_update IS NOT NULL THEN 2
                ELSE 5
            END as threshold_value
        FROM data_quality_checks dqc
        WHERE dqc.hours_since_last_update > 2 
           OR (dqc.null_customer_ids * 100.0 / dqc.total_records) > 5
           OR dqc.invalid_amounts > 0
        
        UNION ALL
        
        -- Business performance alerts
        SELECT 
            'BUSINESS_PERFORMANCE' as alert_category,
            CASE 
                WHEN aca.avg_fraud_score > 0.8 
                THEN 'High fraud risk detected for customer: ' || aca.customer_name || ' (Score: ' || aca.avg_fraud_score || ')'
                WHEN aca.value_trend = 'Declining' AND aca.lifetime_value > 1000
                THEN 'High-value customer declining: ' || aca.customer_name || ' (' || aca.value_change_7d || ' change)'
                WHEN aca.value_trend = 'Accelerating' AND aca.value_change_7d > 500
                THEN 'Customer acceleration opportunity: ' || aca.customer_name || ' (+' || aca.value_change_7d || ')'
            END as alert_message,
            CASE 
                WHEN aca.avg_fraud_score > 0.9 THEN 'CRITICAL'
                WHEN aca.avg_fraud_score > 0.8 THEN 'HIGH'
                WHEN aca.value_trend = 'Declining' AND aca.lifetime_value > 5000 THEN 'HIGH'
                ELSE 'MEDIUM'
            END as alert_severity,
            1 as affected_records,
            COALESCE(aca.avg_fraud_score, ABS(aca.value_change_7d)) as metric_value,
            CASE 
                WHEN aca.avg_fraud_score IS NOT NULL THEN 0.8
                ELSE 100
            END as threshold_value
        FROM advanced_customer_analysis aca
        WHERE aca.avg_fraud_score > 0.8 
           OR (aca.value_trend = 'Declining' AND aca.lifetime_value > 1000)
           OR (aca.value_trend = 'Accelerating' AND aca.value_change_7d > 500)
    ) alerts
    WHERE alert_message IS NOT NULL
),

comprehensive_business_dashboard AS (
    -- Final comprehensive business intelligence dashboard
    SELECT 
        -- Customer intelligence
        aca.customer_id,
        aca.customer_name,
        aca.customer_segment,
        aca.external_segment,
        aca.risk_category,
        CAST(aca.credit_score AS INTEGER) as credit_score,
        CAST(aca.social_score AS DECIMAL(5,2)) as social_media_score,
        
        -- Financial metrics
        aca.lifetime_value,
        aca.revenue_7d,
        aca.avg_transaction_7d,
        aca.value_change_7d,
        aca.value_trend,
        
        -- Behavioral insights
        aca.transaction_count_7d,
        aca.active_days_7d,
        aca.active_hours_7d,
        aca.preferred_hour,
        
        -- Risk assessment
        aca.avg_fraud_score,
        CASE 
            WHEN aca.avg_fraud_score > 0.8 THEN 'High Risk'
            WHEN aca.avg_fraud_score > 0.5 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END as fraud_risk_category,
        
        -- Geographic and demographic context
        aca.city,
        aca.state,
        
        -- Advanced customer scoring
        (CAST(aca.credit_score AS INTEGER) * 0.3 + 
         CAST(aca.social_score AS DECIMAL) * 0.2 + 
         (aca.lifetime_value / 1000) * 0.3 + 
         (100 - aca.avg_fraud_score * 100) * 0.2) as composite_customer_score,
        
        -- Engagement recommendations
        CASE 
            WHEN aca.value_trend = 'Accelerating' THEN 'Upsell Opportunity'
            WHEN aca.value_trend = 'Declining' AND aca.lifetime_value > 1000 THEN 'Retention Campaign'
            WHEN aca.avg_fraud_score > 0.7 THEN 'Enhanced Monitoring'
            WHEN aca.transaction_count_7d = 0 THEN 'Re-engagement Campaign'
            ELSE 'Standard Monitoring'
        END as recommended_action,
        
        -- Real-time timestamp for dashboard freshness
        CURRENT_TIMESTAMP as analysis_timestamp
        
    FROM advanced_customer_analysis aca
    WHERE aca.customer_id IS NOT NULL
)

-- Final output combining all intelligence layers
SELECT 
    -- Customer profile
    cbd.customer_id,
    cbd.customer_name,
    cbd.customer_segment,
    cbd.external_segment,
    cbd.city || ', ' || cbd.state as location,
    
    -- Comprehensive scoring
    cbd.composite_customer_score,
    cbd.credit_score,
    cbd.social_media_score,
    cbd.fraud_risk_category,
    
    -- Financial performance
    cbd.lifetime_value,
    cbd.revenue_7d,
    cbd.value_change_7d,
    cbd.value_trend,
    
    -- Behavioral insights
    cbd.transaction_count_7d,
    cbd.active_days_7d,
    cbd.preferred_hour,
    
    -- Business recommendations
    cbd.recommended_action,
    
    -- Data quality status
    CASE 
        WHEN EXISTS (SELECT 1 FROM business_intelligence_alerts bia WHERE bia.alert_severity = 'CRITICAL')
        THEN 'Data Quality Issues Detected'
        ELSE 'Data Quality Good'
    END as data_quality_status,
    
    -- Alert summary
    (SELECT COUNT(*) FROM business_intelligence_alerts WHERE alert_severity IN ('CRITICAL', 'HIGH')) as high_priority_alerts,
    
    -- Analysis metadata
    cbd.analysis_timestamp

FROM comprehensive_business_dashboard cbd

-- Order by business priority: high-value customers with actionable insights first
ORDER BY 
    CASE cbd.recommended_action
        WHEN 'Enhanced Monitoring' THEN 1
        WHEN 'Retention Campaign' THEN 2
        WHEN 'Upsell Opportunity' THEN 3
        WHEN 'Re-engagement Campaign' THEN 4
        ELSE 5
    END,
    cbd.composite_customer_score DESC,
    cbd.lifetime_value DESC

LIMIT 500;

-- ================================
-- AUTOMATED MONITORING AND MAINTENANCE
-- ================================

-- Create automated views for continuous monitoring
CREATE OR REPLACE VIEW ecommerce.aws_integration_health AS
SELECT 
    'Redshift Spectrum' as service,
    (SELECT COUNT(*) FROM s3_datalake.historical_transactions WHERE transaction_date = CURRENT_DATE - 1) as daily_records,
    CASE 
        WHEN (SELECT COUNT(*) FROM s3_datalake.historical_transactions WHERE transaction_date = CURRENT_DATE - 1) > 0 
        THEN 'Healthy' 
        ELSE 'Issue Detected' 
    END as status,
    CURRENT_TIMESTAMP as last_check
    
UNION ALL

SELECT 
    'Lambda Integration' as service,
    (SELECT COUNT(*) FROM ecommerce.customers WHERE enrich_customer_data(customer_id) IS NOT NULL LIMIT 10) as test_calls,
    CASE 
        WHEN (SELECT COUNT(*) FROM ecommerce.customers WHERE enrich_customer_data(customer_id) IS NOT NULL LIMIT 10) = 10 
        THEN 'Healthy' 
        ELSE 'Issue Detected' 
    END as status,
    CURRENT_TIMESTAMP as last_check;

-- Performance optimization recommendations
ANALYZE ecommerce.sales;
ANALYZE ecommerce.customers;
ANALYZE ecommerce.products;

-- Update table statistics for query optimization
UPDATE ecommerce.customers 
SET lifetime_value = (
    SELECT COALESCE(SUM(total_amount), 0) 
    FROM ecommerce.sales s 
    WHERE s.customer_id = ecommerce.customers.customer_id
)
WHERE customer_id IN (
    SELECT customer_id 
    FROM ecommerce.sales 
    WHERE sale_date >= CURRENT_DATE - 30
);
