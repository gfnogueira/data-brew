{{ config(materialized='ephemeral') }}

WITH items AS (

    SELECT * FROM {{ ref('stg_order_items') }}

),

orders AS (

    SELECT * FROM {{ ref('stg_orders') }}

),

products AS (

    SELECT * FROM {{ ref('stg_products') }}

)

SELECT
    items.order_item_id,
    orders.order_id,
    orders.customer_id,
    orders.order_at,
    orders.order_date,
    orders.status                         AS order_status,
    orders.channel                        AS order_channel,
    products.product_id,
    products.product_name,
    products.category                     AS product_category,
    products.subcategory                  AS product_subcategory,
    items.quantity,
    items.unit_price_cents,
    items.line_amount_cents,
    items.line_amount_cents / 100.0       AS line_amount
FROM items
INNER JOIN orders   USING (order_id)
INNER JOIN products USING (product_id)
