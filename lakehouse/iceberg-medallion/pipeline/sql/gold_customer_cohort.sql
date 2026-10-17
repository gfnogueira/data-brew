with monthly as (
  select
    c.customer_id,
    c.segment,
    date_trunc('month', c.signup_date) as cohort_month,
    o.order_date,
    o.amount
  from customers c
  left join orders o using (customer_id)
)
select
  cohort_month,
  segment,
  count(distinct customer_id)             as cohort_size,
  count(*) filter (where order_date is not null) as orders,
  coalesce(sum(amount), 0)                as revenue
from monthly
group by cohort_month, segment
order by cohort_month, segment
