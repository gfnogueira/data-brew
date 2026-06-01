#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

WAREHOUSE_PATH="${WAREHOUSE_PATH:-./warehouse/poc.duckdb}"

run_query() {
  local label="$1"
  local sql="$2"
  echo "==> ${label}"
  duckdb "${WAREHOUSE_PATH}" -c "${sql}"
  echo
}

run_query "Row counts per mart" "
  SELECT 'dim_customers' AS table_name, count(*) AS rows FROM analytics_marts.dim_customers
  UNION ALL
  SELECT 'dim_products',  count(*) FROM analytics_marts.dim_products
  UNION ALL
  SELECT 'fct_orders',    count(*) FROM analytics_marts.fct_orders
  ORDER BY table_name;
"

run_query "Revenue reconciliation (cents)" "
  SELECT sum(gross_amount_cents)    AS gross_cents,
         sum(net_amount_cents)      AS net_cents,
         sum(refunded_amount_cents) AS refunded_cents,
         sum(gross_amount_cents) - sum(net_amount_cents) - sum(refunded_amount_cents) AS delta_cents
  FROM analytics_marts.fct_orders;
"

run_query "Lifecycle distribution" "
  SELECT lifecycle_stage, count(*) AS customers
  FROM analytics_marts.dim_customers
  GROUP BY lifecycle_stage
  ORDER BY customers DESC;
"

run_query "Top products by revenue" "
  SELECT sku, product_name, units_sold, gross_revenue_amount
  FROM analytics_marts.dim_products
  ORDER BY gross_revenue_cents DESC
  LIMIT 5;
"

echo "Validation completed."
