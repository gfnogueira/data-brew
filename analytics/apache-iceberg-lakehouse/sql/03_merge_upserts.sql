MERGE INTO iceberg.lakehouse.customers target
USING (
  VALUES
    ('CUS-1002', 'Blue Horizon Foods SA', 'enterprise', 'BR', TIMESTAMP '2024-01-11 14:35:00', true),
    ('CUS-1006', 'Apex Industrial', 'smallbiz', 'US', TIMESTAMP '2024-03-08 09:00:00', true)
) AS source (
  customer_id, customer_name, customer_segment, country_code, registration_ts, is_active
)
ON target.customer_id = source.customer_id
WHEN MATCHED THEN UPDATE SET
  customer_name = source.customer_name,
  customer_segment = source.customer_segment,
  country_code = source.country_code,
  registration_ts = source.registration_ts,
  is_active = source.is_active
WHEN NOT MATCHED THEN INSERT (
  customer_id, customer_name, customer_segment, country_code, registration_ts, is_active
) VALUES (
  source.customer_id, source.customer_name, source.customer_segment, source.country_code, source.registration_ts, source.is_active
);

MERGE INTO iceberg.lakehouse.orders target
USING (
  VALUES
    ('ORD-9004', 'CUS-1004', 'completed', TIMESTAMP '2024-03-04 13:45:00', 'USD', DECIMAL '5200.00', DECIMAL '5120.00'),
    ('ORD-9006', 'CUS-1006', 'completed', TIMESTAMP '2024-03-08 10:10:00', 'USD', DECIMAL '4100.00', DECIMAL '4010.00')
) AS source (
  order_id, customer_id, order_status, order_ts, currency_code, gross_amount, net_amount
)
ON target.order_id = source.order_id
WHEN MATCHED THEN UPDATE SET
  customer_id = source.customer_id,
  order_status = source.order_status,
  order_ts = source.order_ts,
  currency_code = source.currency_code,
  gross_amount = source.gross_amount,
  net_amount = source.net_amount
WHEN NOT MATCHED THEN INSERT (
  order_id, customer_id, order_status, order_ts, currency_code, gross_amount, net_amount
) VALUES (
  source.order_id, source.customer_id, source.order_status, source.order_ts, source.currency_code, source.gross_amount, source.net_amount
);
