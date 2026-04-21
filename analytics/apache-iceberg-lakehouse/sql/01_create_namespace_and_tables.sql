CREATE SCHEMA IF NOT EXISTS iceberg.lakehouse
WITH (location = 's3://warehouse/lakehouse/');

CREATE TABLE IF NOT EXISTS iceberg.lakehouse.customers (
  customer_id VARCHAR,
  customer_name VARCHAR,
  customer_segment VARCHAR,
  country_code VARCHAR,
  registration_ts TIMESTAMP(6),
  is_active BOOLEAN
)
WITH (
  format = 'PARQUET',
  partitioning = ARRAY['country_code']
);

CREATE TABLE IF NOT EXISTS iceberg.lakehouse.orders (
  order_id VARCHAR,
  customer_id VARCHAR,
  order_status VARCHAR,
  order_ts TIMESTAMP(6),
  currency_code VARCHAR,
  gross_amount DECIMAL(18,2),
  net_amount DECIMAL(18,2)
)
WITH (
  format = 'PARQUET',
  partitioning = ARRAY['day(order_ts)']
);
