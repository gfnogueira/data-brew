from typing import Any

import pandas as pd
from dagster import AssetExecutionContext, AssetIn, MetadataValue, asset
from dagster_duckdb import DuckDBResource

from platform.partitions import orders_daily_partitions
from platform.policies import curated_freshness, downstream_eager


@asset(
    ins={
        "orders":    AssetIn(key="orders"),
        "products":  AssetIn(key="products"),
    },
    io_manager_key="warehouse_io_manager",
    description="Order line items enriched with product context; persisted in DuckDB.",
    auto_materialize_policy=downstream_eager,
    freshness_policy=curated_freshness,
    partitions_def=orders_daily_partitions,
)
def order_lines(
    context: AssetExecutionContext,
    orders: pd.DataFrame,
    products: pd.DataFrame,
) -> pd.DataFrame:
    enriched = orders.merge(products, on="product_id", how="inner")
    enriched["line_amount_cents"] = enriched["list_price_cents"] * enriched["quantity"]
    enriched = enriched[
        [
            "order_id",
            "order_at",
            "partition_date",
            "customer_id",
            "product_id",
            "category",
            "subcategory",
            "quantity",
            "list_price_cents",
            "line_amount_cents",
            "channel",
            "status",
        ]
    ]
    context.add_output_metadata(
        {
            "partition": context.partition_key,
            "row_count": len(enriched),
            "gross_amount": float(enriched["line_amount_cents"].sum() / 100.0),
        }
    )
    return enriched


@asset(
    deps=[order_lines],
    description="Top categories by net revenue, computed in DuckDB via the warehouse resource.",
    auto_materialize_policy=downstream_eager,
)
def category_revenue(
    context: AssetExecutionContext,
    warehouse: DuckDBResource,
) -> dict[str, Any]:
    with warehouse.get_connection() as conn:
        result = conn.execute(
            """
            SELECT category,
                   sum(line_amount_cents) FILTER (WHERE status = 'paid')      AS net_cents,
                   sum(line_amount_cents) FILTER (WHERE status = 'refunded')  AS refunded_cents
            FROM curated.order_lines
            GROUP BY category
            ORDER BY net_cents DESC
            """
        ).fetchall()

    breakdown = {
        row[0]: {"net_amount": (row[1] or 0) / 100.0, "refunded_amount": (row[2] or 0) / 100.0}
        for row in result
    }
    context.add_output_metadata(
        {
            "categories": MetadataValue.json(breakdown),
            "top_category": result[0][0] if result else None,
        }
    )
    return breakdown
