<<<<<<< HEAD
-- ================================
-- REDSHIFT SAMPLE QUERIES COLLECTION
-- ================================

-- This file contains comprehensive examples of Redshift SQL queries
-- demonstrating various analytical patterns and optimizations

-- ================================
-- 1. BASIC ANALYTICS QUERIES
-- ================================

-- Query 1.1: Simple aggregations
SELECT 
    COUNT(*) as total_transactions,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_transaction,
    MIN(total_amount) as min_transaction,
    MAX(total_amount) as max_transaction,
    STDDEV(total_amount) as stddev_transaction
FROM ecommerce.sales
WHERE sale_date >= CURRENT_DATE - 30;

-- Query 1.2: Sales by date (time series)
SELECT 
    sale_date,
    COUNT(*) as daily_transactions,
    SUM(total_amount) as daily_revenue,
    AVG(total_amount) as avg_daily_transaction,
    COUNT(DISTINCT customer_id) as unique_customers
FROM ecommerce.sales
WHERE sale_date >= CURRENT_DATE - 90
GROUP BY sale_date
ORDER BY sale_date;

-- Query 1.3: Top customers by revenue
SELECT 
    c.customer_name,
    c.customer_segment,
    COUNT(s.sale_id) as transaction_count,
    SUM(s.total_amount) as total_spent,
    AVG(s.total_amount) as avg_transaction,
    MAX(s.sale_date) as last_purchase_date
FROM ecommerce.customers c
JOIN ecommerce.sales s ON c.customer_id = s.customer_id
WHERE s.sale_date >= CURRENT_DATE - 365
GROUP BY c.customer_id, c.customer_name, c.customer_segment
ORDER BY total_spent DESC
LIMIT 20;

-- Query 1.4: Product performance analysis
SELECT 
    p.category,
    p.subcategory,
    p.brand,
    COUNT(s.sale_id) as units_sold,
    SUM(s.total_amount) as revenue,
    AVG(s.total_amount) as avg_sale_price,
    SUM(s.quantity) as total_quantity
FROM ecommerce.products p
JOIN ecommerce.sales s ON p.product_id = s.product_id
WHERE s.sale_date >= CURRENT_DATE - 90
GROUP BY p.category, p.subcategory, p.brand
ORDER BY revenue DESC
LIMIT 50;

-- ================================
-- 2. ADVANCED AGGREGATIONS
-- ================================

-- Query 2.1: Sales with rolling aggregations
SELECT 
    sale_date,
    SUM(total_amount) as daily_revenue,
    AVG(SUM(total_amount)) OVER (
        ORDER BY sale_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as revenue_7day_avg,
    SUM(SUM(total_amount)) OVER (
        ORDER BY sale_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as cumulative_revenue
FROM ecommerce.sales
WHERE sale_date >= CURRENT_DATE - 30
GROUP BY sale_date
ORDER BY sale_date;

-- Query 2.2: Customer segmentation with CASE statements
SELECT 
    customer_segment,
    CASE 
        WHEN total_spent >= 5000 THEN 'High Value'
        WHEN total_spent >= 1000 THEN 'Medium Value'
        WHEN total_spent >= 100 THEN 'Low Value'
        ELSE 'Minimal Value'
    END as value_tier,
    COUNT(*) as customer_count,
    AVG(total_spent) as avg_customer_value,
    SUM(total_spent) as segment_revenue
FROM (
    SELECT 
        c.customer_segment,
        c.customer_id,
        SUM(s.total_amount) as total_spent
    FROM ecommerce.customers c
    JOIN ecommerce.sales s ON c.customer_id = s.customer_id
    WHERE s.sale_date >= CURRENT_DATE - 365
    GROUP BY c.customer_segment, c.customer_id
) customer_totals
GROUP BY customer_segment, value_tier
ORDER BY customer_segment, avg_customer_value DESC;

-- Query 2.3: Monthly cohort analysis
WITH first_purchases AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(sale_date)) as cohort_month
    FROM ecommerce.sales
    GROUP BY customer_id
),
monthly_activity AS (
    SELECT 
        fp.cohort_month,
        DATE_TRUNC('month', s.sale_date) as activity_month,
        COUNT(DISTINCT s.customer_id) as active_customers,
        SUM(s.total_amount) as revenue
    FROM first_purchases fp
    JOIN ecommerce.sales s ON fp.customer_id = s.customer_id
    GROUP BY fp.cohort_month, DATE_TRUNC('month', s.sale_date)
),
cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) as cohort_size
    FROM first_purchases
    GROUP BY cohort_month
)
SELECT 
    ma.cohort_month,
    ma.activity_month,
    DATEDIFF(month, ma.cohort_month, ma.activity_month) as month_number,
    ma.active_customers,
    cs.cohort_size,
    ROUND(100.0 * ma.active_customers / cs.cohort_size, 2) as retention_rate,
    ma.revenue,
    ROUND(ma.revenue / ma.active_customers, 2) as revenue_per_customer
FROM monthly_activity ma
JOIN cohort_sizes cs ON ma.cohort_month = cs.cohort_month
WHERE ma.cohort_month >= '2024-01-01'
ORDER BY ma.cohort_month, ma.activity_month;

-- ================================
-- 3. WINDOW FUNCTIONS
-- ================================

-- Query 3.1: Customer ranking and percentiles
SELECT 
    customer_id,
    customer_name,
    total_spent,
    ROW_NUMBER() OVER (ORDER BY total_spent DESC) as spending_rank,
    RANK() OVER (ORDER BY total_spent DESC) as spending_rank_with_ties,
    DENSE_RANK() OVER (ORDER BY total_spent DESC) as dense_spending_rank,
    NTILE(10) OVER (ORDER BY total_spent DESC) as spending_decile,
    PERCENT_RANK() OVER (ORDER BY total_spent) as spending_percentile,
    CUME_DIST() OVER (ORDER BY total_spent) as spending_cumulative_dist
FROM (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(s.total_amount) as total_spent
    FROM ecommerce.customers c
    JOIN ecommerce.sales s ON c.customer_id = s.customer_id
    WHERE s.sale_date >= CURRENT_DATE - 365
    GROUP BY c.customer_id, c.customer_name
    HAVING SUM(s.total_amount) > 0
) customer_spending
ORDER BY total_spent DESC
LIMIT 100;

-- Query 3.2: Running totals and moving averages by customer
SELECT 
    customer_id,
    sale_date,
    total_amount,
    SUM(total_amount) OVER (
        PARTITION BY customer_id 
        ORDER BY sale_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as running_total,
    AVG(total_amount) OVER (
        PARTITION BY customer_id 
        ORDER BY sale_date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as moving_avg_3_transactions,
    LAG(total_amount, 1) OVER (
        PARTITION BY customer_id 
        ORDER BY sale_date
    ) as previous_transaction,
    LEAD(total_amount, 1) OVER (
        PARTITION BY customer_id 
        ORDER BY sale_date
    ) as next_transaction,
    total_amount - LAG(total_amount, 1) OVER (
        PARTITION BY customer_id 
        ORDER BY sale_date
    ) as transaction_change
FROM ecommerce.sales
WHERE customer_id IN (
    SELECT customer_id 
    FROM ecommerce.sales 
    GROUP BY customer_id 
    HAVING COUNT(*) >= 5
)
ORDER BY customer_id, sale_date
LIMIT 1000;

-- ================================
-- 4. COMPLEX JOINS AND SUBQUERIES
-- ================================

-- Query 4.1: Customer lifetime value analysis
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        c.registration_date,
        MIN(s.sale_date) as first_purchase,
        MAX(s.sale_date) as last_purchase,
        COUNT(s.sale_id) as total_transactions,
        SUM(s.total_amount) as total_spent,
        AVG(s.total_amount) as avg_transaction,
        DATEDIFF(day, MIN(s.sale_date), MAX(s.sale_date)) as customer_lifespan_days
    FROM ecommerce.customers c
    LEFT JOIN ecommerce.sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.customer_name, c.customer_segment, c.registration_date
),
segment_benchmarks AS (
    SELECT 
        customer_segment,
        AVG(total_spent) as segment_avg_spent,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_spent) as segment_median_spent
    FROM customer_metrics
    WHERE total_spent > 0
    GROUP BY customer_segment
)
SELECT 
    cm.customer_id,
    cm.customer_name,
    cm.customer_segment,
    cm.total_transactions,
    cm.total_spent,
    cm.avg_transaction,
    cm.customer_lifespan_days,
    sb.segment_avg_spent,
    ROUND(cm.total_spent - sb.segment_avg_spent, 2) as vs_segment_avg,
    CASE 
        WHEN cm.total_spent > sb.segment_avg_spent * 1.5 THEN 'Above Average'
        WHEN cm.total_spent > sb.segment_avg_spent * 0.5 THEN 'Average'
        ELSE 'Below Average'
    END as performance_vs_segment
FROM customer_metrics cm
LEFT JOIN segment_benchmarks sb ON cm.customer_segment = sb.customer_segment
WHERE cm.total_spent > 0
ORDER BY cm.total_spent DESC
LIMIT 100;

-- Query 4.2: Cross-selling analysis (market basket)
WITH transaction_pairs AS (
    SELECT 
        s1.customer_id,
        s1.sale_date,
        s1.product_id as product_a,
        s2.product_id as product_b
    FROM ecommerce.sales s1
    JOIN ecommerce.sales s2 ON s1.customer_id = s2.customer_id 
                            AND s1.sale_date = s2.sale_date
                            AND s1.product_id < s2.product_id
),
product_combinations AS (
    SELECT 
        product_a,
        product_b,
        COUNT(*) as frequency,
        COUNT(DISTINCT customer_id) as unique_customers
    FROM transaction_pairs
    GROUP BY product_a, product_b
    HAVING COUNT(*) >= 10
)
SELECT 
    p1.product_name as product_a_name,
    p1.category as product_a_category,
    p2.product_name as product_b_name,
    p2.category as product_b_category,
    pc.frequency,
    pc.unique_customers,
    ROUND(pc.frequency * 100.0 / (
        SELECT COUNT(DISTINCT customer_id || sale_date) 
        FROM ecommerce.sales
    ), 4) as support_percentage
FROM product_combinations pc
JOIN ecommerce.products p1 ON pc.product_a = p1.product_id
JOIN ecommerce.products p2 ON pc.product_b = p2.product_id
ORDER BY pc.frequency DESC
LIMIT 20;

-- ================================
-- 5. TIME SERIES ANALYSIS
-- ================================

-- Query 5.1: Seasonal analysis by month and day of week
SELECT 
    EXTRACT(month FROM sale_date) as month,
    TO_CHAR(sale_date, 'Month') as month_name,
    EXTRACT(dow FROM sale_date) as day_of_week,
    TO_CHAR(sale_date, 'Day') as day_name,
    COUNT(*) as transaction_count,
    SUM(total_amount) as revenue,
    AVG(total_amount) as avg_transaction,
    COUNT(DISTINCT customer_id) as unique_customers
FROM ecommerce.sales
WHERE sale_date >= CURRENT_DATE - 365
GROUP BY 
    EXTRACT(month FROM sale_date),
    TO_CHAR(sale_date, 'Month'),
    EXTRACT(dow FROM sale_date),
    TO_CHAR(sale_date, 'Day')
ORDER BY month, day_of_week;

-- Query 5.2: Growth rates and trends
WITH monthly_metrics AS (
    SELECT 
        DATE_TRUNC('month', sale_date) as month,
        COUNT(*) as transactions,
        SUM(total_amount) as revenue,
        COUNT(DISTINCT customer_id) as unique_customers,
        AVG(total_amount) as avg_transaction
    FROM ecommerce.sales
    WHERE sale_date >= DATE_TRUNC('month', CURRENT_DATE - 365)
    GROUP BY DATE_TRUNC('month', sale_date)
)
SELECT 
    month,
    transactions,
    revenue,
    unique_customers,
    avg_transaction,
    LAG(revenue, 1) OVER (ORDER BY month) as prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue, 1) OVER (ORDER BY month)) * 100.0 / 
        LAG(revenue, 1) OVER (ORDER BY month), 2
    ) as revenue_growth_pct,
    LAG(revenue, 12) OVER (ORDER BY month) as same_month_last_year_revenue,
    ROUND(
        (revenue - LAG(revenue, 12) OVER (ORDER BY month)) * 100.0 / 
        LAG(revenue, 12) OVER (ORDER BY month), 2
    ) as yoy_revenue_growth_pct
FROM monthly_metrics
ORDER BY month;

-- ================================
-- 6. CUSTOMER BEHAVIOR ANALYSIS
-- ================================

-- Query 6.1: RFM Analysis (Recency, Frequency, Monetary)
WITH customer_rfm AS (
    SELECT 
        customer_id,
        DATEDIFF(day, MAX(sale_date), CURRENT_DATE) as recency,
        COUNT(sale_id) as frequency,
        SUM(total_amount) as monetary
    FROM ecommerce.sales
    WHERE sale_date >= CURRENT_DATE - 365
    GROUP BY customer_id
),
rfm_percentiles AS (
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC) as recency_score,
        NTILE(5) OVER (ORDER BY frequency) as frequency_score,
        NTILE(5) OVER (ORDER BY monetary) as monetary_score
    FROM customer_rfm
)
SELECT 
    customer_id,
    recency,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    CASE 
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 AND monetary_score >= 4 THEN 'Big Spenders'
        WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score <= 2 THEN 'Potential Loyalists'
        WHEN recency_score >= 4 AND frequency_score <= 1 AND monetary_score <= 2 THEN 'New Customers'
        WHEN recency_score <= 2 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score >= 3 THEN 'Cannot Lose Them'
        WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score <= 2 THEN 'Lost Customers'
        ELSE 'Others'
    END as customer_segment_rfm
FROM rfm_percentiles
ORDER BY monetary DESC;

-- Query 6.2: Customer purchase patterns
SELECT 
    customer_id,
    COUNT(DISTINCT sale_date) as shopping_days,
    COUNT(sale_id) as total_transactions,
    ROUND(COUNT(sale_id) * 1.0 / COUNT(DISTINCT sale_date), 2) as avg_items_per_shopping_day,
    SUM(total_amount) as total_spent,
    AVG(total_amount) as avg_transaction,
    STDDEV(total_amount) as transaction_volatility,
    MIN(sale_date) as first_purchase,
    MAX(sale_date) as last_purchase,
    DATEDIFF(day, MIN(sale_date), MAX(sale_date)) as customer_lifespan,
    ROUND(
        COUNT(sale_id) * 1.0 / GREATEST(DATEDIFF(day, MIN(sale_date), MAX(sale_date)), 1), 3
    ) as purchase_frequency_per_day
FROM ecommerce.sales
WHERE sale_date >= CURRENT_DATE - 365
GROUP BY customer_id
HAVING COUNT(sale_id) >= 3
ORDER BY total_spent DESC
LIMIT 100;

-- ================================
-- 7. PERFORMANCE MONITORING QUERIES
-- ================================

-- Query 7.1: Table sizes and usage
SELECT 
    schemaname,
    tablename,
    size as size_mb,
    pct_used,
    rows,
    unsorted,
    CASE 
        WHEN unsorted > 20 THEN 'Needs VACUUM'
        WHEN unsorted > 5 THEN 'Consider VACUUM'
        ELSE 'Good'
    END as vacuum_recommendation
FROM svv_table_info
WHERE schemaname IN ('ecommerce', 'public')
ORDER BY size DESC;

-- Query 7.2: Query performance analysis
SELECT 
    userid,
    query,
    TRIM(querytxt) as query_text,
    starttime,
    endtime,
    DATEDIFF(second, starttime, endtime) as duration_seconds,
    rows_returned,
    rows_examined
FROM stl_query 
WHERE starttime >= CURRENT_TIMESTAMP - INTERVAL '1 hour'
  AND DATEDIFF(second, starttime, endtime) > 5
ORDER BY duration_seconds DESC
LIMIT 10;

-- ================================
-- 8. DATA QUALITY CHECKS
-- ================================

-- Query 8.1: Comprehensive data quality report
SELECT 'Total Sales Records' as metric, COUNT(*) as value FROM ecommerce.sales
UNION ALL
SELECT 'Null Customer IDs', COUNT(*) FROM ecommerce.sales WHERE customer_id IS NULL
UNION ALL
SELECT 'Null Product IDs', COUNT(*) FROM ecommerce.sales WHERE product_id IS NULL
UNION ALL
SELECT 'Invalid Sale Dates', COUNT(*) FROM ecommerce.sales WHERE sale_date > CURRENT_DATE OR sale_date < '2020-01-01'
UNION ALL
SELECT 'Negative Amounts', COUNT(*) FROM ecommerce.sales WHERE total_amount < 0
UNION ALL
SELECT 'Zero Quantities', COUNT(*) FROM ecommerce.sales WHERE quantity <= 0
UNION ALL
SELECT 'Customers Without Sales', COUNT(*) FROM ecommerce.customers c LEFT JOIN ecommerce.sales s ON c.customer_id = s.customer_id WHERE s.customer_id IS NULL
UNION ALL
SELECT 'Products Without Sales', COUNT(*) FROM ecommerce.products p LEFT JOIN ecommerce.sales s ON p.product_id = s.product_id WHERE s.product_id IS NULL
ORDER BY metric;
=======
-- Count users
SELECT COUNT(*) FROM users;

-- Top domains
SELECT SPLIT_PART(email, '@', 2) AS domain, COUNT(*) AS total
FROM users
GROUP BY domain
ORDER BY total DESC;
>>>>>>> e143233 (Redshift PoC structure with SQL scripts and documentation)
