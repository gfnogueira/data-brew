SELECT customer_segment, country_code, COUNT(*) AS customer_count
FROM iceberg.lakehouse.customers
GROUP BY customer_segment, country_code
ORDER BY customer_segment, country_code;

SELECT
  c.customer_name,
  c.account_manager,
  SUM(o.net_amount) AS total_net_amount,
  SUM(o.discount_amount) AS total_discount_amount
FROM iceberg.lakehouse.orders o
JOIN iceberg.lakehouse.customers c
  ON o.customer_id = c.customer_id
GROUP BY c.customer_name, c.account_manager
ORDER BY total_net_amount DESC;

SELECT
  COUNT(*) AS total_orders,
  COUNT_IF(order_status = 'completed') AS completed_orders,
  ROUND(100.0 * COUNT_IF(order_status = 'completed') / COUNT(*), 2) AS completed_rate_pct
FROM iceberg.lakehouse.orders;

SELECT snapshot_id, committed_at, operation
FROM iceberg.lakehouse."orders$snapshots"
ORDER BY committed_at DESC;
