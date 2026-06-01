{% docs fct_orders_definition %}
Order fact table at order grain. Aggregated from `int_order_items_enriched` to flatten
line-level metrics into order-level totals. Status-aware columns expose net vs refunded
amounts without filtering rows so downstream consumers can pivot freely.
{% enddocs %}

{% docs dim_customers_lifecycle %}
Lifecycle classification rules:
- `active`: at least one paid order in the configured lookback window.
- `dormant`: historical paid orders exist but none inside the lookback window.
- `never_bought`: customer is registered but has no paid orders.

The lookback window is controlled by the project variable `active_customer_lookback_days`.
{% enddocs %}

{% docs dim_products_metrics %}
Product dimension augmented with sales aggregates from paid orders. Units sold, gross
revenue (in cents and decimal), and order counts are precomputed to keep BI queries cheap.
{% enddocs %}
