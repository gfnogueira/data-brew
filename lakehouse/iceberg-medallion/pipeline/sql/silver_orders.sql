with deduped as (
  select
    order_id,
    customer_id,
    cast(amount as decimal(18, 2))              as amount,
    upper(currency)                             as currency,
    cast(ordered_at as timestamp)               as ordered_at,
    row_number() over (
      partition by order_id
      order by ordered_at desc
    ) as rn
  from src
)
select
  order_id,
  customer_id,
  amount,
  currency,
  ordered_at,
  cast(ordered_at as date) as order_date
from deduped
where rn = 1
