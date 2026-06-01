{% macro get_active_window(reference_column='order_at', lookback_var='active_customer_lookback_days') %}
    {{ reference_column }} >= now() - INTERVAL '{{ var(lookback_var) }} days'
{% endmacro %}
