ALTER TABLE iceberg.lakehouse.customers
ADD COLUMN account_manager VARCHAR;

ALTER TABLE iceberg.lakehouse.orders
ADD COLUMN discount_amount DECIMAL(18,2);

UPDATE iceberg.lakehouse.customers
SET account_manager = CASE
  WHEN customer_segment = 'enterprise' THEN 'regional-enterprise-team'
  WHEN customer_segment = 'midmarket' THEN 'midmarket-team'
  ELSE 'inside-sales-team'
END;

UPDATE iceberg.lakehouse.orders
SET discount_amount = gross_amount - net_amount;
