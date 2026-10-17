select
  order_date,
  count(*)                         as orders,
  count(distinct customer_id)      as unique_customers,
  sum(amount)                      as revenue,
  avg(amount)                      as avg_order_value
from orders
group by order_date
order by order_date
