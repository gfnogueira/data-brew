-- script can be run after init.sql to add more data

-- Insert more products for variety
INSERT INTO ecommerce.products (product_name, category, subcategory, brand, price, cost) VALUES
('iPad Pro 12.9"', 'Electronics', 'Tablets', 'Apple', 1099.99, 850.00),
('Surface Pro 9', 'Electronics', 'Tablets', 'Microsoft', 999.99, 750.00),
('AirPods Pro', 'Electronics', 'Headphones', 'Apple', 249.99, 180.00),
('Adidas Ultraboost', 'Clothing', 'Shoes', 'Adidas', 189.99, 120.00),
('H&M T-Shirt', 'Clothing', 'Tops', 'H&M', 19.99, 8.00),
('Canon EOS R5', 'Electronics', 'Cameras', 'Canon', 3899.99, 3200.00),
('Nintendo Switch OLED', 'Electronics', 'Gaming', 'Nintendo', 349.99, 250.00),
('Instant Pot Duo', 'Home', 'Kitchen', 'Instant Pot', 79.99, 50.00);

-- Insert more customers
INSERT INTO ecommerce.customers (first_name, last_name, email, city, state, registration_date, customer_segment) VALUES
('George', 'Taylor', 'george.taylor@email.com', 'Dallas', 'TX', '2023-09-14', 'Regular'),
('Helen', 'Anderson', 'helen.anderson@email.com', 'San Jose', 'CA', '2023-10-08', 'Premium'),
('Ian', 'Thomas', 'ian.thomas@email.com', 'Austin', 'TX', '2023-11-25', 'New'),
('Julia', 'Jackson', 'julia.jackson@email.com', 'Jacksonville', 'FL', '2023-12-03', 'Regular'),
('Kevin', 'White', 'kevin.white@email.com', 'Fort Worth', 'TX', '2024-01-17', 'Premium'),
('Laura', 'Harris', 'laura.harris@email.com', 'Columbus', 'OH', '2024-02-28', 'Regular'),
('Michael', 'Martin', 'michael.martin@email.com', 'Charlotte', 'NC', '2024-03-15', 'New'),
('Nancy', 'Thompson', 'nancy.thompson@email.com', 'San Francisco', 'CA', '2024-04-10', 'Premium');

-- Generate additional sales data
INSERT INTO ecommerce.sales (customer_id, product_id, sale_date, quantity, unit_price, total_amount, payment_method, store_location)
SELECT
    (RANDOM() * 15 + 1)::INTEGER as customer_id,
    (RANDOM() * 15 + 1)::INTEGER as product_id,
    TIMESTAMP '2024-01-01' + (RANDOM() * 120) * INTERVAL '1 day' as sale_date,
    (RANDOM() * 2 + 1)::INTEGER as quantity,
    p.price as unit_price,
    (RANDOM() * 2 + 1)::INTEGER * p.price as total_amount,
    CASE WHEN RANDOM() < 0.5 THEN 'Credit Card' WHEN RANDOM() < 0.75 THEN 'PayPal' WHEN RANDOM() < 0.9 THEN 'Debit Card' ELSE 'Cash' END as payment_method,
    CASE WHEN RANDOM() < 0.3 THEN 'Downtown Store' WHEN RANDOM() < 0.6 THEN 'Mall Location' WHEN RANDOM() < 0.8 THEN 'Online' ELSE 'Outlet Store' END as store_location
FROM ecommerce.products p
CROSS JOIN generate_series(1, 150);