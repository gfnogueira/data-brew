-- Apache Superset PoC - Advanced Analytics Queries
-- KPI calculations, cohort analysis, and business metrics

-- Revenue and Sales KPIs
CREATE OR REPLACE VIEW ecommerce.revenue_kpis AS
SELECT
    DATE_TRUNC('month', sale_date) as metric_month,
    COUNT(*) as total_transactions,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as average_order_value,
    MIN(total_amount) as min_order_value,
    MAX(total_amount) as max_order_value,
    STDDEV(total_amount) as revenue_stddev,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(quantity) as units_sold,
    SUM(total_amount) / NULLIF(SUM(quantity), 0) as avg_price_per_unit
FROM ecommerce.sales
GROUP BY DATE_TRUNC('month', sale_date)
ORDER BY metric_month DESC;

-- Category Performance Analysis
CREATE OR REPLACE VIEW ecommerce.category_performance AS
SELECT
    p.category,
    COUNT(DISTINCT s.sale_id) as transaction_count,
    COUNT(DISTINCT s.customer_id) as unique_customers,
    SUM(s.total_amount) as total_revenue,
    AVG(s.total_amount) as avg_transaction_value,
    SUM(s.quantity) as total_units_sold,
    SUM(s.total_amount - (s.quantity * (p.cost / NULLIF(p.price, 0) * s.unit_price))) as estimated_profit,
    ROUND(100.0 * SUM(s.total_amount) / NULLIF((SELECT SUM(total_amount) FROM ecommerce.sales), 0), 2) as revenue_share_pct
FROM ecommerce.sales s
JOIN ecommerce.products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Customer Lifetime Value Segments
CREATE OR REPLACE VIEW ecommerce.customer_ltv_segments AS
SELECT
    c.customer_segment,
    COUNT(*) as customer_count,
    COUNT(DISTINCT s.customer_id) as active_customers,
    SUM(s.total_amount) as segment_revenue,
    AVG(s.total_amount) as avg_ltv,
    MIN(s.total_amount) as min_ltv,
    MAX(s.total_amount) as max_ltv,
    ROUND(100.0 * COUNT(DISTINCT s.customer_id) / NULLIF(COUNT(DISTINCT c.customer_id), 0), 2) as activation_rate
FROM ecommerce.customers c
LEFT JOIN ecommerce.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_segment
ORDER BY segment_revenue DESC NULLS LAST;

-- Payment Method Analysis
CREATE OR REPLACE VIEW ecommerce.payment_method_analysis AS
SELECT
    payment_method,
    COUNT(*) as transaction_count,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_transaction,
    ROUND(100.0 * COUNT(*) / NULLIF((SELECT COUNT(*) FROM ecommerce.sales), 0), 2) as transaction_share_pct,
    ROUND(100.0 * SUM(total_amount) / NULLIF((SELECT SUM(total_amount) FROM ecommerce.sales), 0), 2) as revenue_share_pct
FROM ecommerce.sales
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Geographic Performance
CREATE OR REPLACE VIEW ecommerce.geographic_performance AS
SELECT
    c.state,
    c.city,
    COUNT(DISTINCT s.sale_id) as sales_count,
    COUNT(DISTINCT s.customer_id) as unique_customers,
    SUM(s.total_amount) as total_revenue,
    AVG(s.total_amount) as avg_order_value,
    SUM(s.total_amount) / COUNT(DISTINCT c.customer_id) as revenue_per_customer
FROM ecommerce.customers c
LEFT JOIN ecommerce.sales s ON c.customer_id = s.customer_id
GROUP BY c.state, c.city
ORDER BY total_revenue DESC NULLS LAST;

-- Store Location Performance
CREATE OR REPLACE VIEW ecommerce.store_performance AS
SELECT
    store_location,
    COUNT(*) as transaction_count,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    MIN(sale_date) as first_sale_date,
    MAX(sale_date) as last_sale_date,
    COUNT(DISTINCT DATE_TRUNC('day', sale_date)) as operating_days
FROM ecommerce.sales
GROUP BY store_location
ORDER BY total_revenue DESC;

-- Customer Cohort Analysis (by registration month)
CREATE OR REPLACE VIEW ecommerce.cohort_analysis AS
SELECT
    DATE_TRUNC('month', c.registration_date) as cohort_month,
    DATE_TRUNC('month', s.sale_date) as sales_month,
    COUNT(DISTINCT s.customer_id) as cohort_customers,
    SUM(s.total_amount) as cohort_revenue,
    ROUND((EXTRACT(EPOCH FROM (s.sale_date - c.registration_date)) / 86400 / 30.44)::INTEGER, 0) as months_since_registration
FROM ecommerce.customers c
LEFT JOIN ecommerce.sales s ON c.customer_id = s.customer_id
WHERE s.sale_date IS NOT NULL
GROUP BY DATE_TRUNC('month', c.registration_date), DATE_TRUNC('month', s.sale_date)
ORDER BY cohort_month DESC, sales_month DESC;

-- Product Brand Comparison
CREATE OR REPLACE VIEW ecommerce.brand_comparison AS
SELECT
    p.brand,
    p.category,
    COUNT(*) as sales_count,
    COUNT(DISTINCT p.product_id) as product_variety,
    COUNT(DISTINCT s.customer_id) as unique_customers,
    SUM(s.total_amount) as total_revenue,
    AVG(s.total_amount) as avg_sale_value,
    SUM(s.quantity) as units_sold,
    ROUND(SUM(s.total_amount) / NULLIF(SUM(s.quantity), 0), 2) as avg_price_per_unit
FROM ecommerce.products p
LEFT JOIN ecommerce.sales s ON p.product_id = s.product_id
WHERE s.sale_id IS NOT NULL
GROUP BY p.brand, p.category
ORDER BY total_revenue DESC NULLS LAST;