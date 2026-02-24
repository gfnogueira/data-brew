-- Raw layer schema for Soda data quality scans
-- Simulates data landing from source systems

CREATE SCHEMA IF NOT EXISTS raw;

-- Customers (raw landing)
CREATE TABLE raw.customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    segment VARCHAR(20),
    city VARCHAR(100),
    state VARCHAR(10),
    registration_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products (raw landing)
CREATE TABLE raw.products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(50),
    subcategory VARCHAR(50),
    unit_price DECIMAL(10,2),
    unit_cost DECIMAL(10,2),
    is_active BOOLEAN DEFAULT TRUE,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders (raw landing)
CREATE TABLE raw.orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    order_date TIMESTAMP NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_pct DECIMAL(5,2) DEFAULT 0,
    status VARCHAR(20) NOT NULL,
    payment_method VARCHAR(50),
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample data: customers
INSERT INTO raw.customers (customer_id, first_name, last_name, email, segment, city, state, registration_date, is_active) VALUES
('CUS001', 'James', 'Wilson', 'james.wilson@techcorp.com', 'Enterprise', 'New York', 'NY', '2024-01-15', true),
('CUS002', 'Sarah', 'Chen', 'sarah.chen@datainc.com', 'Premium', 'San Francisco', 'CA', '2024-02-20', true),
('CUS003', 'Michael', 'Brown', 'michael.brown@analytics.io', 'Standard', 'Chicago', 'IL', '2024-03-10', true),
('CUS004', 'Emily', 'Davis', 'emily.davis@cloudsoft.com', 'Premium', 'Austin', 'TX', '2024-04-05', true),
('CUS005', 'Robert', 'Martinez', 'robert.martinez@bigdata.net', 'Standard', 'Seattle', 'WA', '2024-05-12', true),
('CUS006', 'Jennifer', 'Taylor', 'jennifer.taylor@mlops.co', 'Enterprise', 'Boston', 'MA', '2024-06-18', true),
('CUS007', 'David', 'Anderson', 'david.anderson@dataeng.io', 'Basic', 'Denver', 'CO', '2024-07-22', true),
('CUS008', 'Lisa', 'Thomas', 'lisa.thomas@aiplatform.com', 'Premium', 'Miami', 'FL', '2024-08-30', true),
('CUS009', 'William', 'Jackson', 'william.jackson@techstart.io', 'Standard', 'Portland', 'OR', '2024-09-14', true),
('CUS010', 'Amanda', 'White', 'amanda.white@datasci.com', 'Basic', 'Phoenix', 'AZ', '2024-10-25', true);

-- Sample data: products
INSERT INTO raw.products (product_id, product_name, category, subcategory, unit_price, unit_cost, is_active) VALUES
('PRD001', 'Cloud Storage Basic', 'Infrastructure', 'Storage', 29.99, 12.00, true),
('PRD002', 'Cloud Storage Pro', 'Infrastructure', 'Storage', 79.99, 32.00, true),
('PRD003', 'Cloud Storage Enterprise', 'Infrastructure', 'Storage', 199.99, 80.00, true),
('PRD004', 'Compute Instance Small', 'Infrastructure', 'Compute', 49.99, 20.00, true),
('PRD005', 'Compute Instance Medium', 'Infrastructure', 'Compute', 149.99, 60.00, true),
('PRD006', 'Compute Instance Large', 'Infrastructure', 'Compute', 399.99, 160.00, true),
('PRD007', 'Database PostgreSQL', 'Database', 'Relational', 89.99, 36.00, true),
('PRD008', 'Database MySQL', 'Database', 'Relational', 79.99, 32.00, true),
('PRD009', 'Database MongoDB', 'Database', 'NoSQL', 99.99, 40.00, true),
('PRD010', 'Analytics Platform', 'Analytics', 'BI', 299.99, 120.00, true);

-- Sample data: orders
INSERT INTO raw.orders (order_id, customer_id, product_id, order_date, quantity, unit_price, discount_pct, status, payment_method) VALUES
('ORD0001', 'CUS001', 'PRD003', '2026-01-05 10:30:00', 2, 199.99, 0.10, 'completed', 'credit_card'),
('ORD0002', 'CUS002', 'PRD006', '2026-01-08 14:15:00', 1, 399.99, 0.00, 'completed', 'credit_card'),
('ORD0003', 'CUS003', 'PRD007', '2026-01-10 09:45:00', 3, 89.99, 0.05, 'completed', 'bank_transfer'),
('ORD0004', 'CUS001', 'PRD010', '2026-01-12 16:20:00', 1, 299.99, 0.15, 'completed', 'credit_card'),
('ORD0005', 'CUS004', 'PRD005', '2026-01-15 11:00:00', 2, 149.99, 0.00, 'completed', 'credit_card'),
('ORD0006', 'CUS005', 'PRD004', '2026-01-18 13:30:00', 5, 49.99, 0.10, 'completed', 'bank_transfer'),
('ORD0007', 'CUS006', 'PRD003', '2026-01-20 15:45:00', 3, 199.99, 0.20, 'completed', 'credit_card'),
('ORD0008', 'CUS002', 'PRD002', '2026-01-22 10:00:00', 1, 79.99, 0.00, 'completed', 'credit_card'),
('ORD0009', 'CUS007', 'PRD001', '2026-01-25 14:30:00', 10, 29.99, 0.15, 'completed', 'bank_transfer'),
('ORD0010', 'CUS008', 'PRD006', '2026-01-28 09:15:00', 2, 399.99, 0.05, 'completed', 'credit_card'),
('ORD0011', 'CUS003', 'PRD008', '2026-02-01 11:45:00', 4, 79.99, 0.00, 'completed', 'credit_card'),
('ORD0012', 'CUS009', 'PRD002', '2026-02-05 16:00:00', 3, 79.99, 0.10, 'completed', 'bank_transfer'),
('ORD0013', 'CUS010', 'PRD008', '2026-02-08 10:30:00', 2, 79.99, 0.00, 'completed', 'credit_card'),
('ORD0014', 'CUS001', 'PRD009', '2026-02-10 14:00:00', 1, 99.99, 0.25, 'completed', 'credit_card'),
('ORD0015', 'CUS004', 'PRD010', '2026-02-12 09:30:00', 2, 299.99, 0.00, 'pending', 'credit_card');

-- Indexes for common filters
CREATE INDEX idx_raw_orders_customer ON raw.orders(customer_id);
CREATE INDEX idx_raw_orders_product ON raw.orders(product_id);
CREATE INDEX idx_raw_orders_order_date ON raw.orders(order_date);
CREATE INDEX idx_raw_customers_segment ON raw.customers(segment);
CREATE INDEX idx_raw_products_category ON raw.products(category);
