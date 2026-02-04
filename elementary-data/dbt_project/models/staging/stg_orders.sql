-- Staging model for order data
-- Applies data typing and calculates totals

with source as (
    select * from {{ ref('raw_orders') }}
),

staged as (
    select
        order_id,
        customer_id,
        product_id,
        cast(order_date as timestamp) as order_date,
        cast(order_date as date) as order_date_day,
        quantity,
        cast(unit_price as decimal(10,2)) as unit_price,
        cast(discount_pct as decimal(5,2)) as discount_pct,
        cast(quantity * unit_price as decimal(10,2)) as gross_amount,
        cast(quantity * unit_price * (1 - discount_pct) as decimal(10,2)) as net_amount,
        cast(quantity * unit_price * discount_pct as decimal(10,2)) as discount_amount,
        status,
        payment_method,
        current_timestamp as _loaded_at
    from source
)

select * from staged
