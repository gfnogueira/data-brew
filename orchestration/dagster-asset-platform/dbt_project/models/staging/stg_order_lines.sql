{{ config(materialized='view') }}

select
    order_id,
    order_at,
    customer_id,
    product_id,
    category,
    subcategory,
    quantity,
    list_price_cents,
    line_amount_cents,
    channel,
    lower(status) as status
from curated.order_lines
