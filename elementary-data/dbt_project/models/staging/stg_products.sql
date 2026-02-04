-- Staging model for product data
-- Applies data typing and calculates margin

with source as (
    select * from {{ ref('raw_products') }}
),

staged as (
    select
        product_id,
        product_name,
        category,
        subcategory,
        cast(unit_price as decimal(10,2)) as unit_price,
        cast(unit_cost as decimal(10,2)) as unit_cost,
        cast(unit_price - unit_cost as decimal(10,2)) as unit_margin,
        round((unit_price - unit_cost) / unit_price * 100, 2) as margin_pct,
        is_active,
        current_timestamp as _loaded_at
    from source
)

select * from staged
