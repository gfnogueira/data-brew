{{ config(materialized='table') }}

select
    channel,
    count(*)                                                  as orders,
    sum(net_cents)        / 100.0                             as net_amount,
    sum(refunded_cents)   / 100.0                             as refunded_amount,
    round(
        sum(refunded_cents) / nullif(sum(gross_cents), 0)::float, 4
    )                                                         as refund_rate
from {{ ref('mart_orders') }}
group by channel
order by net_amount desc
