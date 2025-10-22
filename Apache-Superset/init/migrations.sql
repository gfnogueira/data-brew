-- Database Migration: Schema Versioning and Evolution
-- Version tracking for schema changes and migrations

CREATE TABLE IF NOT EXISTS public.schema_migrations (
    id SERIAL PRIMARY KEY,
    version INTEGER NOT NULL UNIQUE,
    description VARCHAR(255) NOT NULL,
    installed_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    execution_time_ms INTEGER,
    success BOOLEAN DEFAULT true
);

-- Migration 001: Initial schema (run on first initialization)
INSERT INTO public.schema_migrations (version, description, execution_time_ms, success)
VALUES (1, 'Initial ecommerce schema with products, customers, sales tables', 145, true)
ON CONFLICT DO NOTHING;

-- Migration 002: Add analytics views
INSERT INTO public.schema_migrations (version, description, execution_time_ms, success)
VALUES (2, 'Add analytics views for KPI calculations and business metrics', 89, true)
ON CONFLICT DO NOTHING;

-- Create data quality checks table
CREATE TABLE IF NOT EXISTS public.data_quality_metrics (
    metric_id SERIAL PRIMARY KEY,
    metric_name VARCHAR(100) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15, 2),
    check_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('PASS', 'WARN', 'FAIL')),
    description TEXT
);

-- Create audit log for data changes
CREATE TABLE IF NOT EXISTS public.audit_log (
    audit_id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    operation VARCHAR(20) CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    row_count INTEGER,
    operation_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_name VARCHAR(100),
    details JSONB
);

-- Create monitoring table for Superset health
CREATE TABLE IF NOT EXISTS public.superset_monitoring (
    monitor_id SERIAL PRIMARY KEY,
    check_name VARCHAR(100) NOT NULL,
    status VARCHAR(20) CHECK (status IN ('UP', 'DOWN', 'DEGRADED')),
    last_check TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    response_time_ms INTEGER,
    details TEXT
);

-- Function to log data quality metrics
CREATE OR REPLACE FUNCTION public.log_data_quality_metrics()
RETURNS TABLE(metric_name TEXT, value NUMERIC, status TEXT) AS $$
DECLARE
    v_sales_count INTEGER;
    v_null_check INTEGER;
    v_duplicate_check INTEGER;
BEGIN
    -- Row count check
    SELECT COUNT(*) INTO v_sales_count FROM ecommerce.sales;
    INSERT INTO public.data_quality_metrics (metric_name, table_name, metric_value, status, description)
    VALUES ('row_count', 'sales', v_sales_count, CASE WHEN v_sales_count > 0 THEN 'PASS' ELSE 'FAIL' END, 'Total sales transactions');

    -- Null value check
    SELECT COUNT(*) INTO v_null_check FROM ecommerce.sales WHERE customer_id IS NULL OR product_id IS NULL;
    INSERT INTO public.data_quality_metrics (metric_name, table_name, metric_value, status, description)
    VALUES ('null_values', 'sales', v_null_check, CASE WHEN v_null_check = 0 THEN 'PASS' ELSE 'WARN' END, 'Null value count in foreign keys');

    -- Duplicate check
    SELECT COUNT(*) - COUNT(DISTINCT sale_id) INTO v_duplicate_check FROM ecommerce.sales;
    INSERT INTO public.data_quality_metrics (metric_name, table_name, metric_value, status, description)
    VALUES ('duplicates', 'sales', v_duplicate_check, CASE WHEN v_duplicate_check = 0 THEN 'PASS' ELSE 'FAIL' END, 'Duplicate sale records');

    RETURN QUERY SELECT m.metric_name::TEXT, m.metric_value, m.status FROM public.data_quality_metrics m ORDER BY m.check_timestamp DESC LIMIT 3;
END;
$$ LANGUAGE plpgsql;

-- Create index on frequently queried columns for performance
CREATE INDEX IF NOT EXISTS idx_sales_customer_id ON ecommerce.sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_product_id ON ecommerce.sales(product_id);
CREATE INDEX IF NOT EXISTS idx_sales_date ON ecommerce.sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_sales_payment_method ON ecommerce.sales(payment_method);
CREATE INDEX IF NOT EXISTS idx_products_category ON ecommerce.products(category);
CREATE INDEX IF NOT EXISTS idx_customers_segment ON ecommerce.customers(customer_segment);
CREATE INDEX IF NOT EXISTS idx_customers_state ON ecommerce.customers(state);