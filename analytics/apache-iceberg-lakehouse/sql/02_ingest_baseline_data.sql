INSERT INTO iceberg.lakehouse.customers (
  customer_id, customer_name, customer_segment, country_code, registration_ts, is_active
)
VALUES
  ('CUS-1001', 'Northwind Retail', 'enterprise', 'US', TIMESTAMP '2024-01-03 10:15:00', true),
  ('CUS-1002', 'Blue Horizon Foods', 'midmarket', 'BR', TIMESTAMP '2024-01-11 14:35:00', true),
  ('CUS-1003', 'Atlas Mobility', 'enterprise', 'DE', TIMESTAMP '2024-01-19 09:20:00', true),
  ('CUS-1004', 'Vertex Med Group', 'midmarket', 'US', TIMESTAMP '2024-02-01 08:55:00', true),
  ('CUS-1005', 'Nova Energy', 'smallbiz', 'BR', TIMESTAMP '2024-02-07 16:40:00', true);

INSERT INTO iceberg.lakehouse.orders (
  order_id, customer_id, order_status, order_ts, currency_code, gross_amount, net_amount
)
VALUES
  ('ORD-9001', 'CUS-1001', 'completed', TIMESTAMP '2024-03-01 10:00:00', 'USD', DECIMAL '12850.00', DECIMAL '12420.00'),
  ('ORD-9002', 'CUS-1002', 'completed', TIMESTAMP '2024-03-02 11:30:00', 'BRL', DECIMAL '8240.50', DECIMAL '8010.50'),
  ('ORD-9003', 'CUS-1003', 'completed', TIMESTAMP '2024-03-03 09:10:00', 'EUR', DECIMAL '15300.00', DECIMAL '14990.00'),
  ('ORD-9004', 'CUS-1004', 'pending',   TIMESTAMP '2024-03-04 13:45:00', 'USD', DECIMAL '5200.00', DECIMAL '5200.00'),
  ('ORD-9005', 'CUS-1005', 'completed', TIMESTAMP '2024-03-05 15:05:00', 'BRL', DECIMAL '2960.00', DECIMAL '2890.00');
