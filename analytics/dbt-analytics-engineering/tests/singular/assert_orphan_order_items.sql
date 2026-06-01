-- Every line item must resolve to an existing order in fct_orders.

SELECT
    items.order_item_id,
    items.order_id
FROM {{ ref('stg_order_items') }} items
LEFT JOIN {{ ref('fct_orders') }} orders USING (order_id)
WHERE orders.order_id IS NULL
