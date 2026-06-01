{% docs __overview__ %}

# E-Commerce Analytics

This dbt project models an e-commerce dataset using a layered design.

- **Raw**: seeded source-of-record extracts for customers, products, orders, and order items.
- **Staging**: light normalization and type casting, materialized as views to keep the layer cheap.
- **Intermediate**: ephemeral joins that enrich line items with order and product context.
- **Marts**: persisted star schema with `dim_customers`, `dim_products`, and `fct_orders`.
- **Snapshots**: SCD type 2 history for customers and products to support point-in-time analysis.
- **Exposures**: downstream consumers (BI dashboards and ML feature views) declared for lineage.

Open the generated docs with `dbt docs serve` after running `dbt docs generate` to navigate
the full DAG, see column descriptions, and inspect tests.

{% enddocs %}
