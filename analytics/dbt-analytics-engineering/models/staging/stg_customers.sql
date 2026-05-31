{{ config(materialized='view') }}

WITH raw AS (

    SELECT * FROM {{ source('raw', 'customers') }}

)

SELECT
    customer_id,
    lower(trim(email))                  AS email,
    initcap(first_name)                 AS first_name,
    initcap(last_name)                  AS last_name,
    upper(country)                      AS country_code,
    signup_date,
    lower(tier)                         AS tier
FROM raw
