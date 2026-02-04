"""
Synthetic data generator for retail analytics.

Generates realistic transactional data including products, customers,
stores, and sales transactions for analytical workloads.
"""

import os
import random
from datetime import datetime, timedelta
from pathlib import Path

import pandas as pd
from faker import Faker

# Configuration
NUM_PRODUCTS = 500
NUM_CUSTOMERS = 2000
NUM_STORES = 25
NUM_TRANSACTIONS = 50000
DATE_RANGE_DAYS = 365

OUTPUT_DIR = Path(__file__).parent.parent / "data" / "raw"

fake = Faker()
Faker.seed(42)
random.seed(42)


def generate_products() -> pd.DataFrame:
    """Generate product catalog with categories and pricing."""
    categories = {
        "Electronics": {"price_range": (99.99, 1999.99), "margin": 0.25},
        "Clothing": {"price_range": (19.99, 299.99), "margin": 0.45},
        "Home & Garden": {"price_range": (29.99, 599.99), "margin": 0.35},
        "Sports": {"price_range": (24.99, 499.99), "margin": 0.30},
        "Books": {"price_range": (9.99, 79.99), "margin": 0.40},
        "Food & Beverage": {"price_range": (2.99, 49.99), "margin": 0.20},
        "Health & Beauty": {"price_range": (9.99, 199.99), "margin": 0.50},
        "Automotive": {"price_range": (14.99, 399.99), "margin": 0.28},
    }

    products = []
    product_id = 1

    for category, config in categories.items():
        category_count = NUM_PRODUCTS // len(categories)
        for _ in range(category_count):
            price = round(random.uniform(*config["price_range"]), 2)
            cost = round(price * (1 - config["margin"]), 2)
            products.append({
                "product_id": f"PRD{product_id:06d}",
                "product_name": fake.catch_phrase(),
                "category": category,
                "subcategory": fake.word().capitalize(),
                "brand": fake.company().split()[0],
                "unit_price": price,
                "unit_cost": cost,
                "stock_quantity": random.randint(0, 1000),
                "is_active": random.choices([True, False], weights=[0.95, 0.05])[0],
                "created_at": fake.date_between(start_date="-3y", end_date="-1y"),
            })
            product_id += 1

    return pd.DataFrame(products)


def generate_customers() -> pd.DataFrame:
    """Generate customer data with demographics and segments."""
    segments = ["Premium", "Standard", "Basic", "Enterprise"]
    segment_weights = [0.10, 0.50, 0.35, 0.05]

    customers = []
    for i in range(1, NUM_CUSTOMERS + 1):
        registration_date = fake.date_between(start_date="-5y", end_date="-30d")
        customers.append({
            "customer_id": f"CUS{i:08d}",
            "first_name": fake.first_name(),
            "last_name": fake.last_name(),
            "email": fake.email(),
            "phone": fake.phone_number(),
            "segment": random.choices(segments, weights=segment_weights)[0],
            "city": fake.city(),
            "state": fake.state_abbr(),
            "country": "US",
            "postal_code": fake.zipcode(),
            "registration_date": registration_date,
            "is_active": random.choices([True, False], weights=[0.85, 0.15])[0],
        })

    return pd.DataFrame(customers)


def generate_stores() -> pd.DataFrame:
    """Generate store locations with regional information."""
    regions = {
        "Northeast": ["NY", "MA", "PA", "NJ", "CT"],
        "Southeast": ["FL", "GA", "NC", "VA", "TN"],
        "Midwest": ["IL", "OH", "MI", "IN", "WI"],
        "Southwest": ["TX", "AZ", "NM", "OK", "CO"],
        "West": ["CA", "WA", "OR", "NV", "UT"],
    }

    stores = []
    store_id = 1

    for region, states in regions.items():
        stores_per_region = NUM_STORES // len(regions)
        for _ in range(stores_per_region):
            state = random.choice(states)
            stores.append({
                "store_id": f"STR{store_id:04d}",
                "store_name": f"{fake.city()} Store",
                "region": region,
                "state": state,
                "city": fake.city(),
                "address": fake.street_address(),
                "postal_code": fake.zipcode(),
                "store_type": random.choice(["Flagship", "Standard", "Outlet"]),
                "square_footage": random.randint(5000, 50000),
                "opened_date": fake.date_between(start_date="-10y", end_date="-1y"),
                "manager_name": fake.name(),
            })
            store_id += 1

    return pd.DataFrame(stores)


def generate_transactions(
    products: pd.DataFrame,
    customers: pd.DataFrame,
    stores: pd.DataFrame
) -> pd.DataFrame:
    """Generate sales transactions with realistic patterns."""
    product_ids = products["product_id"].tolist()
    product_prices = dict(zip(products["product_id"], products["unit_price"]))
    customer_ids = customers["customer_id"].tolist()
    store_ids = stores["store_id"].tolist()

    payment_methods = ["Credit Card", "Debit Card", "Cash", "Digital Wallet"]
    payment_weights = [0.45, 0.25, 0.15, 0.15]

    end_date = datetime.now()
    start_date = end_date - timedelta(days=DATE_RANGE_DAYS)

    transactions = []
    for i in range(1, NUM_TRANSACTIONS + 1):
        product_id = random.choice(product_ids)
        unit_price = product_prices[product_id]
        quantity = random.choices(
            [1, 2, 3, 4, 5],
            weights=[0.50, 0.25, 0.15, 0.07, 0.03]
        )[0]

        # Apply discount based on quantity
        discount_pct = 0.0
        if quantity >= 3:
            discount_pct = random.choice([0.05, 0.10, 0.15])

        transaction_date = fake.date_time_between(
            start_date=start_date,
            end_date=end_date
        )

        transactions.append({
            "transaction_id": f"TXN{i:010d}",
            "transaction_date": transaction_date,
            "customer_id": random.choice(customer_ids),
            "product_id": product_id,
            "store_id": random.choice(store_ids),
            "quantity": quantity,
            "unit_price": unit_price,
            "discount_pct": discount_pct,
            "total_amount": round(quantity * unit_price * (1 - discount_pct), 2),
            "payment_method": random.choices(payment_methods, weights=payment_weights)[0],
            "is_returned": random.choices([False, True], weights=[0.97, 0.03])[0],
        })

    return pd.DataFrame(transactions)


def main():
    """Generate all datasets and save to CSV."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("Generating products...")
    products = generate_products()
    products.to_csv(OUTPUT_DIR / "products.csv", index=False)
    print(f"  Created {len(products)} products")

    print("Generating customers...")
    customers = generate_customers()
    customers.to_csv(OUTPUT_DIR / "customers.csv", index=False)
    print(f"  Created {len(customers)} customers")

    print("Generating stores...")
    stores = generate_stores()
    stores.to_csv(OUTPUT_DIR / "stores.csv", index=False)
    print(f"  Created {len(stores)} stores")

    print("Generating transactions...")
    transactions = generate_transactions(products, customers, stores)
    transactions.to_csv(OUTPUT_DIR / "transactions.csv", index=False)
    print(f"  Created {len(transactions)} transactions")

    print(f"\nAll files saved to: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
