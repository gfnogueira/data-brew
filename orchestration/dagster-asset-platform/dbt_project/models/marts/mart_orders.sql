{{ config(materialized='table') }}

with lines as (

    select * from {{ ref('stg_order_lines') }}

)

select
    order_id,
    customer_id,
    min(order_at)                                                   as order_at,
    sum(quantity)                                                   as items_count,
    sum(line_amount_cents)                                          as gross_cents,
    sum(line_amount_cents) filter (where status = 'paid')           as net_cents,
    sum(line_amount_cents) filter (where status = 'refunded')       as refunded_cents,
    any_value(channel)                                              as channel,
    max(status)                                                     as status
from lines
group by order_id, customer_id
