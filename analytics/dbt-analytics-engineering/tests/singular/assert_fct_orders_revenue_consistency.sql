-- Net plus refunded revenue must equal gross revenue for every order.

SELECT
    order_id,
    gross_amount_cents,
    net_amount_cents,
    refunded_amount_cents,
    (net_amount_cents + refunded_amount_cents) AS reconstructed_gross_cents
FROM {{ ref('fct_orders') }}
WHERE (net_amount_cents + refunded_amount_cents) <> gross_amount_cents
