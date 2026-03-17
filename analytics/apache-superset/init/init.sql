-- Apache Superset db init
-- e-commerce data

-- Create schema
CREATE SCHEMA IF NOT EXISTS ecommerce;

-- Products table
CREATE TABLE IF NOT EXISTS ecommerce.products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    price DECIMAL(10,2),
    cost DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customers table
CREATE TABLE IF NOT EXISTS ecommerce.customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    city VARCHAR(100),
    state VARCHAR(50),
    registration_date DATE,
    customer_segment VARCHAR(50)
);

-- Sales table
CREATE TABLE IF NOT EXISTS ecommerce.sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES ecommerce.customers(customer_id),
    product_id INTEGER REFERENCES ecommerce.products(product_id),
    sale_date TIMESTAMP,
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    store_location VARCHAR(100)
);

-- Insert sample products
INSERT INTO ecommerce.products (product_name, category, subcategory, brand, price, cost) VALUES
('iPhone 15 Pro', 'Electronics', 'Smartphones', 'Apple', 999.99, 750.00),
('MacBook Air M3', 'Electronics', 'Laptops', 'Apple', 1299.99, 950.00),
('Samsung Galaxy S24', 'Electronics', 'Smartphones', 'Samsung', 799.99, 600.00),
('Dell XPS 13', 'Electronics', 'Laptops', 'Dell', 1099.99, 800.00),
('Nike Air Max', 'Clothing', 'Shoes', 'Nike', 129.99, 80.00),
('Levi''s Jeans', 'Clothing', 'Pants', 'Levi''s', 79.99, 40.00),
('Sony WH-1000XM5', 'Electronics', 'Headphones', 'Sony', 349.99, 250.00),
('Kindle Paperwhite', 'Electronics', 'E-readers', 'Amazon', 139.99, 90.00);

-- Insert sample customers
INSERT INTO ecommerce.customers (first_name, last_name, email, city, state, registration_date, customer_segment) VALUES
('John', 'Doe', 'john.doe@email.com', 'New York', 'NY', '2023-01-15', 'Premium'),
('Jane', 'Smith', 'jane.smith@email.com', 'Los Angeles', 'CA', '2023-02-20', 'Regular'),
('Bob', 'Johnson', 'bob.johnson@email.com', 'Chicago', 'IL', '2023-03-10', 'Premium'),
('Alice', 'Williams', 'alice.williams@email.com', 'Houston', 'TX', '2023-04-05', 'Regular'),
('Charlie', 'Brown', 'charlie.brown@email.com', 'Phoenix', 'AZ', '2023-05-12', 'New'),
('Diana', 'Davis', 'diana.davis@email.com', 'Philadelphia', 'PA', '2023-06-18', 'Premium'),
('Edward', 'Miller', 'edward.miller@email.com', 'San Antonio', 'TX', '2023-07-22', 'Regular'),
('Fiona', 'Wilson', 'fiona.wilson@email.com', 'San Diego', 'CA', '2023-08-30', 'New');

-- Generate sales data for the last 6 months
INSERT INTO ecommerce.sales (customer_id, product_id, sale_date, quantity, unit_price, total_amount, payment_method, store_location)
SELECT
    (RANDOM() * 7 + 1)::INTEGER as customer_id,
    (RANDOM() * 7 + 1)::INTEGER as product_id,
    TIMESTAMP '2024-04-01' + (RANDOM() * 180) * INTERVAL '1 day' as sale_date,
    (RANDOM() * 3 + 1)::INTEGER as quantity,
    p.price as unit_price,
    (RANDOM() * 3 + 1)::INTEGER * p.price as total_amount,
    CASE WHEN RANDOM() < 0.6 THEN 'Credit Card' WHEN RANDOM() < 0.8 THEN 'Debit Card' ELSE 'Cash' END as payment_method,
    CASE WHEN RANDOM() < 0.4 THEN 'Downtown Store' WHEN RANDOM() < 0.7 THEN 'Mall Location' ELSE 'Online' END as store_location
FROM ecommerce.products p
CROSS JOIN generate_series(1, 200);

-- Create some useful views for Superset
CREATE OR REPLACE VIEW ecommerce.sales_summary AS
SELECT
    DATE_TRUNC('month', sale_date) as sale_month,
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    COUNT(DISTINCT customer_id) as unique_customers
FROM ecommerce.sales
GROUP BY DATE_TRUNC('month', sale_date)
ORDER BY sale_month;

CREATE OR REPLACE VIEW ecommerce.product_performance AS
SELECT
    p.product_name,
    p.category,
    p.brand,
    COUNT(s.sale_id) as units_sold,
    SUM(s.total_amount) as total_revenue,
    AVG(s.total_amount) as avg_sale_price,
    MAX(s.sale_date) as last_sale_date
FROM ecommerce.products p
LEFT JOIN ecommerce.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category, p.brand
ORDER BY total_revenue DESC;

CREATE OR REPLACE VIEW ecommerce.customer_analytics AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    c.customer_segment,
    c.city,
    c.state,
    COUNT(s.sale_id) as total_orders,
    SUM(s.total_amount) as lifetime_value,
    AVG(s.total_amount) as avg_order_value,
    MAX(s.sale_date) as last_purchase_date,
    MIN(s.sale_date) as first_purchase_date
FROM ecommerce.customers c
LEFT JOIN ecommerce.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.customer_segment, c.city, c.state
ORDER BY lifetime_value DESC;