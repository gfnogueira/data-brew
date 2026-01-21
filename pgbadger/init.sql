-- Initialize database with sample data and queries for pgBadger analysis

-- Create sample table
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

-- Insert sample data
INSERT INTO users (username, email) VALUES
    ('alice', 'alice@example.com'),
    ('bob', 'bob@example.com'),
    ('charlie', 'charlie@example.com');

INSERT INTO orders (user_id, amount, status) VALUES
    (1, 100.50, 'completed'),
    (1, 250.75, 'pending'),
    (2, 75.00, 'completed'),
    (3, 500.00, 'completed');

-- Generate some query activity for analysis
SELECT COUNT(*) FROM users;
SELECT * FROM users WHERE username = 'alice';
SELECT u.username, COUNT(o.id) as order_count 
FROM users u 
LEFT JOIN orders o ON u.id = o.user_id 
GROUP BY u.id, u.username;

-- Slow query simulation
SELECT pg_sleep(0.1);

-- Complex query
SELECT 
    u.username,
    SUM(o.amount) as total_amount,
    COUNT(o.id) as order_count
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.status = 'completed'
GROUP BY u.id, u.username
HAVING SUM(o.amount) > 100
ORDER BY total_amount DESC;
