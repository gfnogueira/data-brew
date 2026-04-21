SELECT snapshot_id, committed_at, operation
FROM iceberg.lakehouse."orders$snapshots"
ORDER BY committed_at DESC;

SELECT order_id, order_status, net_amount
FROM iceberg.lakehouse.orders
FOR VERSION AS OF (
  SELECT max_by(snapshot_id, committed_at)
  FROM iceberg.lakehouse."orders$snapshots"
)
ORDER BY order_id;

-- Rollback command template (execute only when explicitly needed):
-- ALTER TABLE iceberg.lakehouse.orders
-- EXECUTE rollback_to_snapshot(snapshot_id => <snapshot_id>);
