from datetime import datetime, timedelta, timezone
from random import Random
from uuid import uuid4

import pandas as pd
from dagster import AssetExecutionContext, MetadataValue, asset

from platform.partitions import orders_daily_partitions
from platform.policies import raw_eager

# Seed kept stable so the asset graph is reproducible across runs.
RNG = Random(2026)

COUNTRIES = ("BR", "US", "DE", "FR", "JP", "ES", "AR", "IT", "PT", "AU")
TIERS = ("free", "starter", "pro", "enterprise")
CHANNELS = ("web", "ios", "android")
STATUSES = ("paid", "paid", "paid", "paid", "refunded")
CATEGORIES = (
    ("electronics", "peripherals"),
    ("electronics", "displays"),
    ("electronics", "audio"),
    ("home", "lighting"),
    ("home", "appliances"),
    ("grocery", "beverage"),
    ("fitness", "accessories"),
)


@asset(
    description="Synthesized customer accounts used as the root of the asset graph.",
    auto_materialize_policy=raw_eager,
)
def customers(context: AssetExecutionContext) -> pd.DataFrame:
    rows = []
    base = datetime(2025, 1, 1, tzinfo=timezone.utc)
    for i in range(1, 41):
        signup = base + timedelta(days=RNG.randint(0, 320))
        rows.append(
            {
                "customer_id": i,
                "email": f"user{i:03d}@example.com",
                "country": RNG.choice(COUNTRIES),
                "tier": RNG.choice(TIERS),
                "signup_date": signup.date(),
            }
        )
    df = pd.DataFrame(rows)
    context.add_output_metadata(
        {
            "row_count": len(df),
            "tiers": MetadataValue.json(df["tier"].value_counts().to_dict()),
        }
    )
    return df


@asset(
    description="Active product catalog with stable SKU mapping.",
    auto_materialize_policy=raw_eager,
)
def products(context: AssetExecutionContext) -> pd.DataFrame:
    rows = []
    for i in range(1, 31):
        category, subcategory = CATEGORIES[i % len(CATEGORIES)]
        rows.append(
            {
                "product_id": i,
                "sku": f"SKU-{i:03d}",
                "category": category,
                "subcategory": subcategory,
                "list_price_cents": RNG.choice([1990, 2990, 4990, 7990, 12990, 19990, 38900]),
                "is_active": True,
            }
        )
    df = pd.DataFrame(rows)
    context.add_output_metadata(
        {
            "row_count": len(df),
            "categories": MetadataValue.json(df["category"].value_counts().to_dict()),
        }
    )
    return df


@asset(
    deps=["customers", "products"],
    description="Daily-partitioned orders cross-referencing customers and products.",
    partitions_def=orders_daily_partitions,
)
def orders(context: AssetExecutionContext) -> pd.DataFrame:
    partition_date = datetime.fromisoformat(context.partition_key).replace(tzinfo=timezone.utc)
    rows = []
    # Roughly 200-300 events per day, dispersed across the 24h window.
    for _ in range(RNG.randint(200, 300)):
        order_at = partition_date + timedelta(minutes=RNG.randint(0, 24 * 60 - 1))
        rows.append(
            {
                "order_id": str(uuid4()),
                "customer_id": RNG.randint(1, 40),
                "product_id": RNG.randint(1, 30),
                "quantity": RNG.randint(1, 4),
                "order_at": order_at,
                "channel": RNG.choice(CHANNELS),
                "status": RNG.choice(STATUSES),
                "partition_date": partition_date.date(),
            }
        )
    df = pd.DataFrame(rows)
    context.add_output_metadata(
        {
            "partition": context.partition_key,
            "row_count": len(df),
            "refund_share": float((df["status"] == "refunded").mean()),
        }
    )
    return df
