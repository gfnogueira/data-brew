{{ config(materialized='table') }}

WITH customers AS (

    SELECT * FROM {{ ref('stg_customers') }}

),

orders AS (

    SELECT * FROM {{ ref('stg_orders') }}

),

customer_orders AS (

    SELECT
        customer_id,
        min(order_at)                                AS first_order_at,
        max(order_at)                                AS most_recent_order_at,
        count(DISTINCT order_id)                     AS total_orders,
        count(DISTINCT order_id) FILTER (
            WHERE order_at >= now() - INTERVAL '{{ var("active_customer_lookback_days") }} days'
        )                                            AS recent_orders
    FROM orders
    WHERE status = 'paid'
    GROUP BY customer_id

)

SELECT
    customers.customer_id,
    customers.email,
    customers.first_name,
    customers.last_name,
    customers.country_code,
    customers.signup_date,
    customers.tier,
    coalesce(customer_orders.total_orders, 0)        AS total_orders,
    coalesce(customer_orders.recent_orders, 0)       AS recent_orders,
    customer_orders.first_order_at,
    customer_orders.most_recent_order_at,
    CASE
        WHEN customer_orders.recent_orders > 0 THEN 'active'
        WHEN customer_orders.total_orders   > 0 THEN 'dormant'
        ELSE 'never_bought'
    END                                              AS lifecycle_stage
FROM customers
LEFT JOIN customer_orders USING (customer_id)
