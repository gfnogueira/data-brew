{{ config(materialized='view') }}

WITH raw AS (

    SELECT * FROM {{ source('raw', 'products') }}

)

SELECT
    product_id,
    sku,
    name                                 AS product_name,
    lower(category)                      AS category,
    lower(subcategory)                   AS subcategory,
    list_price_cents,
    list_price_cents / 100.0             AS list_price_amount,
    is_active
FROM raw
