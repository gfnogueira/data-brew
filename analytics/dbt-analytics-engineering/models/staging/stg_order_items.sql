{{ config(materialized='view') }}

WITH raw AS (

    SELECT * FROM {{ source('raw', 'order_items') }}

)

SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price_cents,
    unit_price_cents * quantity          AS line_amount_cents
FROM raw
