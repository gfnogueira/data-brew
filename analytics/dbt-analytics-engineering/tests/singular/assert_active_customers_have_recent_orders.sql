-- A customer flagged as active must have at least one order inside the lookback window.

SELECT
    customer_id,
    lifecycle_stage,
    recent_orders
FROM {{ ref('dim_customers') }}
WHERE lifecycle_stage = 'active'
  AND coalesce(recent_orders, 0) = 0
