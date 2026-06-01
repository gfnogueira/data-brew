{{ config(materialized='table') }}

WITH order_lines AS (

    SELECT
        order_id,
        customer_id,
        order_at,
        order_date,
        order_status,
        order_channel,
        sum(quantity)                                AS items_count,
        sum(line_amount_cents)                       AS gross_amount_cents,
        sum(line_amount_cents) / 100.0               AS gross_amount,
        count(DISTINCT product_id)                   AS distinct_products
    FROM {{ ref('int_order_items_enriched') }}
    GROUP BY order_id, customer_id, order_at, order_date, order_status, order_channel

)

SELECT
    order_id,
    customer_id,
    order_at,
    order_date,
    order_status,
    order_channel,
    items_count,
    distinct_products,
    gross_amount_cents,
    gross_amount,
    CASE WHEN order_status = 'paid'     THEN gross_amount_cents ELSE 0 END AS net_amount_cents,
    CASE WHEN order_status = 'paid'     THEN gross_amount       ELSE 0 END AS net_amount,
    CASE WHEN order_status = 'refunded' THEN gross_amount_cents ELSE 0 END AS refunded_amount_cents
FROM order_lines
