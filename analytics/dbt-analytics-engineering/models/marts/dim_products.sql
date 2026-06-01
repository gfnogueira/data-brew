{{ config(materialized='table') }}

WITH products AS (

    SELECT * FROM {{ ref('stg_products') }}

),

product_metrics AS (

    SELECT
        product_id,
        sum(quantity)                                AS units_sold,
        sum(line_amount_cents)                       AS gross_revenue_cents,
        count(DISTINCT order_id)                     AS orders_count
    FROM {{ ref('int_order_items_enriched') }}
    WHERE order_status = 'paid'
    GROUP BY product_id

)

SELECT
    products.product_id,
    products.sku,
    products.product_name,
    products.category,
    products.subcategory,
    products.list_price_cents,
    products.list_price_amount,
    products.is_active,
    coalesce(product_metrics.units_sold,         0)     AS units_sold,
    coalesce(product_metrics.gross_revenue_cents, 0)     AS gross_revenue_cents,
    coalesce(product_metrics.gross_revenue_cents, 0) / 100.0 AS gross_revenue_amount,
    coalesce(product_metrics.orders_count,        0)     AS orders_count
FROM products
LEFT JOIN product_metrics USING (product_id)
