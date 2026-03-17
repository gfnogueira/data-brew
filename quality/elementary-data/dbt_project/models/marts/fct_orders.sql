-- Fact table for orders
-- Enriched with product and customer attributes

with orders as (
    select * from {{ ref('stg_orders') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

enriched as (
    select
        o.order_id,
        o.order_date,
        o.order_date_day,
        
        -- Customer attributes
        o.customer_id,
        c.full_name as customer_name,
        c.segment as customer_segment,
        c.state as customer_state,
        
        -- Product attributes
        o.product_id,
        p.product_name,
        p.category as product_category,
        p.subcategory as product_subcategory,
        
        -- Order metrics
        o.quantity,
        o.unit_price,
        o.discount_pct,
        o.gross_amount,
        o.net_amount,
        o.discount_amount,
        
        -- Cost and margin
        p.unit_cost,
        cast(o.quantity * p.unit_cost as decimal(10,2)) as total_cost,
        cast(o.net_amount - (o.quantity * p.unit_cost) as decimal(10,2)) as gross_profit,
        
        o.status,
        o.payment_method,
        o._loaded_at
        
    from orders o
    left join products p on o.product_id = p.product_id
    left join customers c on o.customer_id = c.customer_id
)

select * from enriched
