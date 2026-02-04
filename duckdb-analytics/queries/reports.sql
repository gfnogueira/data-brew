-- DuckDB Analytics - SQL Query Templates
-- These queries demonstrate common analytical patterns

-- =============================================================================
-- REVENUE ANALYSIS
-- =============================================================================

-- Total revenue by category with margin analysis
SELECT 
    p.category,
    COUNT(DISTINCT t.transaction_id) AS transactions,
    SUM(t.quantity) AS units_sold,
    ROUND(SUM(t.total_amount), 2) AS revenue,
    ROUND(SUM(t.quantity * p.unit_cost), 2) AS cost,
    ROUND(SUM(t.total_amount) - SUM(t.quantity * p.unit_cost), 2) AS gross_profit,
    ROUND(100.0 * (SUM(t.total_amount) - SUM(t.quantity * p.unit_cost)) / SUM(t.total_amount), 1) AS margin_pct
FROM transactions t
JOIN products p ON t.product_id = p.product_id
WHERE t.is_returned = FALSE
GROUP BY p.category
ORDER BY revenue DESC;

-- =============================================================================
-- TIME SERIES ANALYSIS
-- =============================================================================

-- Daily sales with 7-day moving average
WITH daily_sales AS (
    SELECT 
        DATE_TRUNC('day', transaction_date) AS sale_date,
        COUNT(*) AS transactions,
        SUM(total_amount) AS revenue
    FROM transactions
    WHERE is_returned = FALSE
    GROUP BY DATE_TRUNC('day', transaction_date)
)
SELECT 
    sale_date,
    transactions,
    ROUND(revenue, 2) AS revenue,
    ROUND(AVG(revenue) OVER (
        ORDER BY sale_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS revenue_7d_ma
FROM daily_sales
ORDER BY sale_date DESC
LIMIT 30;

-- Month-over-month growth
WITH monthly AS (
    SELECT 
        DATE_TRUNC('month', transaction_date) AS month,
        SUM(total_amount) AS revenue
    FROM transactions
    WHERE is_returned = FALSE
    GROUP BY DATE_TRUNC('month', transaction_date)
)
SELECT 
    STRFTIME(month, '%Y-%m') AS month,
    ROUND(revenue, 2) AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS prev_month_revenue,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) 
          / LAG(revenue) OVER (ORDER BY month), 1) AS growth_pct
FROM monthly
ORDER BY month;

-- =============================================================================
-- CUSTOMER ANALYSIS
-- =============================================================================

-- Customer cohort analysis by registration month
SELECT 
    DATE_TRUNC('month', c.registration_date) AS cohort_month,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT t.customer_id) AS active_customers,
    ROUND(100.0 * COUNT(DISTINCT t.customer_id) / COUNT(DISTINCT c.customer_id), 1) AS activation_rate,
    ROUND(SUM(t.total_amount), 2) AS total_revenue,
    ROUND(SUM(t.total_amount) / COUNT(DISTINCT t.customer_id), 2) AS revenue_per_active
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id AND t.is_returned = FALSE
GROUP BY DATE_TRUNC('month', c.registration_date)
ORDER BY cohort_month;

-- RFM Analysis (Recency, Frequency, Monetary)
WITH customer_metrics AS (
    SELECT 
        customer_id,
        DATE_DIFF('day', MAX(transaction_date), CURRENT_DATE) AS recency_days,
        COUNT(DISTINCT transaction_id) AS frequency,
        SUM(total_amount) AS monetary
    FROM transactions
    WHERE is_returned = FALSE
    GROUP BY customer_id
)
SELECT 
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency) AS f_score,
    NTILE(5) OVER (ORDER BY monetary) AS m_score
FROM customer_metrics
ORDER BY monetary DESC
LIMIT 100;

-- =============================================================================
-- PRODUCT ANALYSIS
-- =============================================================================

-- Top performing products
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    COUNT(DISTINCT t.transaction_id) AS transactions,
    SUM(t.quantity) AS units_sold,
    ROUND(SUM(t.total_amount), 2) AS revenue,
    ROUND(AVG(t.total_amount), 2) AS avg_transaction
FROM products p
JOIN transactions t ON p.product_id = t.product_id
WHERE t.is_returned = FALSE
GROUP BY p.product_id, p.product_name, p.category, p.brand
ORDER BY revenue DESC
LIMIT 20;

-- Product affinity analysis (frequently bought together)
WITH product_pairs AS (
    SELECT 
        t1.product_id AS product_a,
        t2.product_id AS product_b,
        COUNT(*) AS co_occurrence
    FROM transactions t1
    JOIN transactions t2 ON t1.customer_id = t2.customer_id 
        AND t1.product_id < t2.product_id
        AND DATE_DIFF('day', t1.transaction_date, t2.transaction_date) BETWEEN -7 AND 7
    WHERE t1.is_returned = FALSE AND t2.is_returned = FALSE
    GROUP BY t1.product_id, t2.product_id
    HAVING COUNT(*) >= 5
)
SELECT 
    pp.product_a,
    p1.product_name AS product_a_name,
    pp.product_b,
    p2.product_name AS product_b_name,
    pp.co_occurrence
FROM product_pairs pp
JOIN products p1 ON pp.product_a = p1.product_id
JOIN products p2 ON pp.product_b = p2.product_id
ORDER BY co_occurrence DESC
LIMIT 20;

-- =============================================================================
-- STORE ANALYSIS
-- =============================================================================

-- Store performance ranking
SELECT 
    s.store_id,
    s.store_name,
    s.region,
    s.store_type,
    COUNT(DISTINCT t.transaction_id) AS transactions,
    ROUND(SUM(t.total_amount), 2) AS revenue,
    ROUND(SUM(t.total_amount) / s.square_footage, 2) AS revenue_per_sqft,
    RANK() OVER (PARTITION BY s.region ORDER BY SUM(t.total_amount) DESC) AS region_rank
FROM stores s
JOIN transactions t ON s.store_id = t.store_id
WHERE t.is_returned = FALSE
GROUP BY s.store_id, s.store_name, s.region, s.store_type, s.square_footage
ORDER BY revenue DESC;

-- =============================================================================
-- DATA QUALITY CHECKS
-- =============================================================================

-- Orphan records check
SELECT 
    'Transactions without valid product' AS check_type,
    COUNT(*) AS record_count
FROM transactions t
LEFT JOIN products p ON t.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT 
    'Transactions without valid customer' AS check_type,
    COUNT(*) AS record_count
FROM transactions t
LEFT JOIN customers c ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 
    'Transactions without valid store' AS check_type,
    COUNT(*) AS record_count
FROM transactions t
LEFT JOIN stores s ON t.store_id = s.store_id
WHERE s.store_id IS NULL;

-- Duplicate transaction check
SELECT 
    transaction_id,
    COUNT(*) AS occurrences
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;
