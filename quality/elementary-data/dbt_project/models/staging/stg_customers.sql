-- Staging model for customer data
-- Applies data typing and basic transformations

with source as (
    select * from {{ ref('raw_customers') }}
),

staged as (
    select
        customer_id,
        first_name,
        last_name,
        concat(first_name, ' ', last_name) as full_name,
        lower(email) as email,
        upper(segment) as segment,
        city,
        upper(state) as state,
        cast(registration_date as date) as registration_date,
        is_active,
        current_timestamp as _loaded_at
    from source
)

select * from staged
