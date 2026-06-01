{% snapshot products_snapshot %}

    {{
        config(
            target_schema='snapshots',
            unique_key='product_id',
            strategy='check',
            check_cols=['product_name', 'category', 'subcategory', 'list_price_cents', 'is_active']
        )
    }}

    SELECT
        product_id,
        sku,
        product_name,
        category,
        subcategory,
        list_price_cents,
        is_active,
        current_timestamp AS captured_at
    FROM {{ ref('stg_products') }}

{% endsnapshot %}
