-- Initialize database with sample data and queries for pg_activity monitoring

-- Create sample tables
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    amount DECIMAL(10,2),
    status VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2),
    stock INTEGER DEFAULT 0
);

-- Insert sample data
INSERT INTO users (username, email) VALUES
    ('alice', 'alice@example.com'),
    ('bob', 'bob@example.com'),
    ('charlie', 'charlie@example.com'),
    ('diana', 'diana@example.com'),
    ('eve', 'eve@example.com');

INSERT INTO orders (user_id, amount, status) VALUES
    (1, 100.50, 'completed'),
    (1, 250.75, 'pending'),
    (2, 75.00, 'completed'),
    (3, 500.00, 'completed'),
    (4, 150.00, 'pending'),
    (5, 300.00, 'completed');

INSERT INTO products (name, price, stock) VALUES
    ('Laptop', 999.99, 10),
    ('Mouse', 29.99, 50),
    ('Keyboard', 79.99, 30),
    ('Monitor', 299.99, 15);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Grant necessary permissions for monitoring
GRANT pg_monitor TO postgres;

-- Function to generate some activity (for monitoring demo)
CREATE OR REPLACE FUNCTION generate_activity()
RETURNS void AS $$
BEGIN
    -- Various query types to monitor
    PERFORM COUNT(*) FROM users;
    PERFORM * FROM users WHERE username = 'alice';
    PERFORM u.username, COUNT(o.id) as order_count 
    FROM users u 
    LEFT JOIN orders o ON u.id = o.user_id 
    GROUP BY u.id, u.username;
    
    -- Update operations
    UPDATE orders SET status = 'processing' WHERE status = 'pending' LIMIT 1;
    
    -- Insert operations
    INSERT INTO orders (user_id, amount, status) 
    VALUES (1, 99.99, 'pending');
    
    -- Complex join query
    PERFORM 
        u.username,
        SUM(o.amount) as total_amount,
        COUNT(o.id) as order_count
    FROM users u
    JOIN orders o ON u.id = o.user_id
    WHERE o.status = 'completed'
    GROUP BY u.id, u.username
    HAVING SUM(o.amount) > 100
    ORDER BY total_amount DESC;
END;
$$ LANGUAGE plpgsql;
