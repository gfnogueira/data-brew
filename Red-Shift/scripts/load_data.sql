-- ================================
-- REDSHIFT DATA LOADING
-- ================================

-- This file demonstrates various data loading patterns and best practices

-- ================================
-- 1. BASIC TABLE CREATION AND LOADING
-- ================================

-- Create sample ecommerce tables with proper distribution and sort keys
CREATE SCHEMA IF NOT EXISTS ecommerce;

-- Customers dimension table (small, distribute to all nodes)
CREATE TABLE IF NOT EXISTS ecommerce.customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(150),
    registration_date DATE,
    customer_segment VARCHAR(20),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    lifetime_value DECIMAL(12,2)
)
DISTSTYLE ALL  -- Small dimension table, replicate everywhere
SORTKEY (registration_date, customer_segment);

-- Products dimension table (small, distribute to all nodes)
CREATE TABLE IF NOT EXISTS ecommerce.products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(200),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    unit_price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
DISTSTYLE ALL  -- Small dimension table, replicate everywhere
SORTKEY (category, subcategory);

-- Sales fact table (large, distribute by customer_id for joins)
CREATE TABLE IF NOT EXISTS ecommerce.sales (
    sale_id BIGINT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    sale_date DATE,
    sale_timestamp TIMESTAMP,
    quantity SMALLINT,
    unit_price DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    total_amount DECIMAL(12,2),
    payment_method VARCHAR(20),
    sales_channel VARCHAR(20)
)
DISTSTYLE KEY
DISTKEY (customer_id)  -- Distribute by customer_id for optimal joins
COMPOUND SORTKEY (sale_date, customer_id);  -- Sort by date first, then customer

-- ================================
-- 2. COPY COMMANDS FROM S3
-- ================================

-- Load customers data from S3
COPY ecommerce.customers (
    customer_id,
    customer_name,
    email,
    registration_date,
    customer_segment,
    city,
    state,
    country,
    lifetime_value
)
FROM 's3://bucket-name/ecommerce-data/customers/'
IAM_ROLE 'arn:aws:iam::ACCOUNT-ID:role/RedshiftRole'
FORMAT AS CSV
IGNOREHEADER 1
DATEFORMAT 'YYYY-MM-DD'
TIMEFORMAT 'YYYY-MM-DD HH:MI:SS'
REGION 'us-east-1'
COMPUPDATE ON;

-- Load products data from S3
COPY ecommerce.products (
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    unit_price,
    created_at
)
FROM 's3://bucket-name/ecommerce-data/products/'
IAM_ROLE 'arn:aws:iam::ACCOUNT-ID:role/RedshiftRole'
FORMAT AS CSV
IGNOREHEADER 1
DATEFORMAT 'YYYY-MM-DD'
TIMEFORMAT 'YYYY-MM-DD HH:MI:SS'
REGION 'us-east-1'
COMPUPDATE ON;

-- Load sales data from S3 (partitioned by date for efficiency)
COPY ecommerce.sales (
    sale_id,
    customer_id,
    product_id,
    sale_date,
    sale_timestamp,
    quantity,
    unit_price,
    discount_amount,
    total_amount,
    payment_method,
    sales_channel
)
FROM 's3://bucket-name/ecommerce-data/sales/'
IAM_ROLE 'arn:aws:iam::ACCOUNT-ID:role/RedshiftRole'
FORMAT AS CSV
IGNOREHEADER 1
DATEFORMAT 'YYYY-MM-DD'
TIMEFORMAT 'YYYY-MM-DD HH:MI:SS'
REGION 'us-east-1'
COMPUPDATE ON
MAXERROR 100;  -- Allow up to 100 errors before failing

-- ================================
-- 3. LOADING FROM PARQUET FILES
-- ================================

-- Load from Parquet (more efficient format)
COPY ecommerce.sales_parquet
FROM 's3://bucket-name/ecommerce-data/sales-parquet/'
IAM_ROLE 'arn:aws:iam::ACCOUNT-ID:role/RedshiftRole'
FORMAT AS PARQUET
REGION 'us-east-1';

-- ================================
-- 4. LOADING WITH MANIFEST FILES
-- ================================

-- Create manifest file for better control over which files to load
-- Manifest file (s3://bucket/manifest.json) content:
/*
{
  "entries": [
    {"url":"s3://bucket/sales/2024/01/sales_20240101.csv", "mandatory":true},
    {"url":"s3://bucket/sales/2024/01/sales_20240102.csv", "mandatory":true},
    {"url":"s3://bucket/sales/2024/01/sales_20240103.csv", "mandatory":false}
  ]
}
*/

COPY ecommerce.sales
FROM 's3://bucket-name/manifests/sales_manifest.json'
IAM_ROLE 'arn:aws:iam::ACCOUNT-ID:role/RedshiftRole'
FORMAT AS CSV
IGNOREHEADER 1
MANIFEST
REGION 'us-east-1';

-- ================================
-- 5. LOADING WITH ENCRYPTION
-- ================================

-- Load encrypted data from S3
COPY ecommerce.sensitive_data
FROM 's3://bucket-name/encrypted-data/'
IAM_ROLE 'arn:aws:iam::ACCOUNT-ID:role/RedshiftRole'
FORMAT AS CSV
ENCRYPTED
REGION 'us-east-1';

-- ================================
-- 6. UPSERT OPERATIONS (MERGE)
-- ================================

-- Create staging table for upserts
CREATE TEMP TABLE stage_customers (LIKE ecommerce.customers);

-- Load new/updated data into staging
COPY stage_customers
FROM 's3://bucket-name/customer-updates/'
IAM_ROLE 'arn:aws:iam::ACCOUNT-ID:role/RedshiftRole'
FORMAT AS CSV
IGNOREHEADER 1;

-- Perform UPSERT using DELETE + INSERT pattern
BEGIN TRANSACTION;

-- Delete existing records that will be updated
DELETE FROM ecommerce.customers 
WHERE customer_id IN (SELECT customer_id FROM stage_customers);

-- Insert new and updated records
INSERT INTO ecommerce.customers 
SELECT * FROM stage_customers;

END TRANSACTION;

-- ================================
-- 7. INCREMENTAL LOADING
-- ================================

-- Load only new records since last load
COPY ecommerce.sales_incremental
FROM 's3://bucket-name/sales/incremental/'
IAM_ROLE 'arn:aws:iam::ACCOUNT-ID:role/RedshiftRole'
FORMAT AS CSV
IGNOREHEADER 1
WHERE sale_date > (SELECT COALESCE(MAX(sale_date), '1900-01-01') FROM ecommerce.sales);

-- ================================
-- 8. ERROR HANDLING AND MONITORING
-- ================================

-- Check for COPY errors
SELECT 
    session,
    query,
    filename,
    line_number,
    column_name,
    type,
    error_message
FROM stl_load_errors
WHERE session = pg_backend_pid()
ORDER BY starttime DESC;

-- Check COPY command history
SELECT 
    query,
    filename,
    curtime,
    rows_loaded,
    rows_to_load
FROM stl_load_commits
WHERE filename LIKE '%bucket-name%'
ORDER BY curtime DESC
LIMIT 10;

-- ================================
-- 9. PERFORMANCE OPTIMIZATION
-- ================================

-- Analyze compression after loading
ANALYZE COMPRESSION ecommerce.sales;

-- Update table statistics
ANALYZE ecommerce.customers;
ANALYZE ecommerce.products;
ANALYZE ecommerce.sales;

-- Check table statistics
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    most_common_vals
FROM pg_stats 
WHERE schemaname = 'ecommerce'
ORDER BY schemaname, tablename, attname;

-- ================================
-- 10. VALIDATION QUERIES
-- ================================

-- Validate data load
SELECT 'customers' as table_name, COUNT(*) as record_count FROM ecommerce.customers
UNION ALL
SELECT 'products' as table_name, COUNT(*) as record_count FROM ecommerce.products
UNION ALL
SELECT 'sales' as table_name, COUNT(*) as record_count FROM ecommerce.sales;

-- Check data quality
SELECT 
    'Null customer_ids in sales' as check_name,
    COUNT(*) as issues
FROM ecommerce.sales 
WHERE customer_id IS NULL

UNION ALL

SELECT 
    'Invalid sale dates' as check_name,
    COUNT(*) as issues  
FROM ecommerce.sales
WHERE sale_date > CURRENT_DATE OR sale_date < '2020-01-01'

UNION ALL

SELECT 
    'Negative sale amounts' as check_name,
    COUNT(*) as issues
FROM ecommerce.sales
WHERE total_amount < 0;

-- Data range validation
SELECT 
    MIN(sale_date) as earliest_sale,
    MAX(sale_date) as latest_sale,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(DISTINCT product_id) as unique_products,
    SUM(total_amount) as total_revenue
FROM ecommerce.sales;
