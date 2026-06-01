{% snapshot customers_snapshot %}

    {{
        config(
            target_schema='snapshots',
            unique_key='customer_id',
            strategy='check',
            check_cols=['email', 'first_name', 'last_name', 'country_code', 'tier']
        )
    }}

    SELECT
        customer_id,
        email,
        first_name,
        last_name,
        country_code,
        signup_date,
        tier,
        current_timestamp AS captured_at
    FROM {{ ref('stg_customers') }}

{% endsnapshot %}
