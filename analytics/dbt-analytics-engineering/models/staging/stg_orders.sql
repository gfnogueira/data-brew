{{ config(materialized='view') }}

WITH raw AS (

    SELECT * FROM {{ source('raw', 'orders') }}

)

SELECT
    order_id,
    customer_id,
    order_at,
    date_trunc('day', order_at)::date    AS order_date,
    lower(status)                        AS status,
    lower(channel)                       AS channel
FROM raw
