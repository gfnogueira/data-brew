-- ============================================
-- E-Commerce Sample Schema
-- ============================================

-- Customers table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    city VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(10, 2) NOT NULL,
    stock INTEGER DEFAULT 0
);

-- Sales table
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    sale_date DATE NOT NULL
);

-- ============================================
-- Sample Data
-- ============================================

-- Insert customers (100 records)
INSERT INTO customers (name, email, city) VALUES
('Alice Johnson', 'alice@email.com', 'New York'),
('Bob Smith', 'bob@email.com', 'Los Angeles'),
('Carol White', 'carol@email.com', 'Chicago'),
('David Brown', 'david@email.com', 'Houston'),
('Emma Davis', 'emma@email.com', 'Phoenix'),
('Frank Wilson', 'frank@email.com', 'Philadelphia'),
('Grace Lee', 'grace@email.com', 'San Antonio'),
('Henry Taylor', 'henry@email.com', 'San Diego'),
('Ivy Martinez', 'ivy@email.com', 'Dallas'),
('Jack Anderson', 'jack@email.com', 'San Jose');

-- Generate more customers
INSERT INTO customers (name, email, city)
SELECT 
    'Customer ' || i,
    'customer' || i || '@email.com',
    (ARRAY['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Miami', 'Seattle', 'Denver', 'Boston', 'Atlanta'])[1 + (i % 10)]
FROM generate_series(11, 100) AS i;

-- Insert products (20 records)
INSERT INTO products (name, category, price, stock) VALUES
('Laptop Pro 15', 'Electronics', 1299.99, 50),
('Wireless Mouse', 'Electronics', 29.99, 200),
('USB-C Hub', 'Electronics', 49.99, 150),
('Mechanical Keyboard', 'Electronics', 149.99, 75),
('Monitor 27"', 'Electronics', 399.99, 40),
('Webcam HD', 'Electronics', 79.99, 100),
('Headphones Pro', 'Electronics', 199.99, 80),
('Office Chair', 'Furniture', 299.99, 30),
('Standing Desk', 'Furniture', 599.99, 20),
('Desk Lamp', 'Furniture', 39.99, 120),
('Notebook Set', 'Office', 12.99, 300),
('Pen Pack', 'Office', 8.99, 500),
('Whiteboard', 'Office', 89.99, 45),
('Coffee Mug', 'Kitchen', 14.99, 200),
('Water Bottle', 'Kitchen', 24.99, 180),
('Backpack', 'Accessories', 79.99, 90),
('Phone Stand', 'Accessories', 19.99, 250),
('Cable Organizer', 'Accessories', 9.99, 400),
('Mouse Pad XL', 'Accessories', 29.99, 150),
('Screen Cleaner', 'Accessories', 7.99, 300);

-- Generate sales (1000 records)
INSERT INTO sales (customer_id, product_id, quantity, total_amount, sale_date)
SELECT 
    1 + (random() * 99)::int AS customer_id,
    1 + (random() * 19)::int AS product_id,
    1 + (random() * 4)::int AS quantity,
    (10 + random() * 500)::decimal(10,2) AS total_amount,
    DATE '2024-01-01' + (random() * 365)::int AS sale_date
FROM generate_series(1, 1000);

-- ============================================
-- Basic View for Schema Context
-- ============================================
CREATE OR REPLACE VIEW v_sales_summary AS
SELECT 
    c.name AS customer_name,
    c.city,
    p.name AS product_name,
    p.category,
    s.quantity,
    s.total_amount,
    s.sale_date
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id;

-- Comments for LLM context
COMMENT ON TABLE customers IS 'Customer information including name, email and location';
COMMENT ON TABLE products IS 'Product catalog with pricing and inventory';
COMMENT ON TABLE sales IS 'Sales transactions linking customers and products';
COMMENT ON VIEW v_sales_summary IS 'Denormalized view joining sales with customer and product details';
