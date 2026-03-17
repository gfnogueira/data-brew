-- Customer dimension with aggregated metrics

with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
    where status = 'completed'
),

customer_metrics as (
    select
        customer_id,
        count(distinct order_id) as total_orders,
        sum(net_amount) as total_revenue,
        avg(net_amount) as avg_order_value,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        count(distinct order_date_day) as distinct_order_days
    from orders
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.full_name,
        c.email,
        c.segment,
        c.city,
        c.state,
        c.registration_date,
        c.is_active,
        
        -- Order metrics
        coalesce(m.total_orders, 0) as total_orders,
        coalesce(m.total_revenue, 0) as total_revenue,
        coalesce(m.avg_order_value, 0) as avg_order_value,
        m.first_order_date,
        m.last_order_date,
        coalesce(m.distinct_order_days, 0) as distinct_order_days,
        
        -- Calculated fields
        case
            when m.total_revenue >= 1000 then 'High Value'
            when m.total_revenue >= 500 then 'Medium Value'
            when m.total_revenue > 0 then 'Low Value'
            else 'No Orders'
        end as value_tier,
        
        c._loaded_at
        
    from customers c
    left join customer_metrics m on c.customer_id = m.customer_id
)

select * from final
