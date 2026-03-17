#!/usr/bin/env python3
"""
Real-time data generator for Apache Superset demo with Podman
Optimized for presentation environments with Podman containers
"""

import time
import random
import json
import sys
from datetime import datetime, timezone
from typing import Dict, List, Any

# Configuration for Podman environment
DEMO_CONFIG = {
    "duration_minutes": 3,
    "transactions_per_second": 0.8,  # Slightly higher rate for impact
    "db_config": {
        "host": "localhost",
        "port": 5432,
        "database": "superset_db", 
        "user": "superset",
        "password": "superset123"
    }
}

# Enhanced demo data for better presentation impact
CUSTOMERS = [
    "Emma Johnson", "Liam Smith", "Olivia Brown", "Noah Davis", "Ava Wilson",
    "Ethan Miller", "Sophia Moore", "Mason Taylor", "Isabella Anderson", "Logan Thomas",
    "Mia Jackson", "Lucas White", "Amelia Harris", "Benjamin Martin", "Charlotte Thompson",
    "James Wilson", "Harper Lee", "Alexander Clark", "Evelyn Martinez", "Sebastian Garcia"
]

# Products optimized for demo storytelling
PRODUCTS = {
    "Electronics": [
        {"name": "iPhone 15 Pro Max", "price_range": (1199, 1399), "popularity": 0.9},
        {"name": "Samsung Galaxy S24 Ultra", "price_range": (999, 1199), "popularity": 0.8},
        {"name": "MacBook Pro M3", "price_range": (1599, 2399), "popularity": 0.7},
        {"name": "iPad Pro 12.9", "price_range": (999, 1299), "popularity": 0.8},
        {"name": "AirPods Pro 2", "price_range": (249, 249), "popularity": 0.95},
        {"name": "Sony WH-1000XM5", "price_range": (349, 399), "popularity": 0.6},
        {"name": "Nintendo Switch OLED", "price_range": (349, 349), "popularity": 0.7},
        {"name": "Tesla Model Y", "price_range": (52000, 65000), "popularity": 0.1}  # High-value outlier
    ],
    "Fashion": [
        {"name": "Nike Air Force 1", "price_range": (90, 130), "popularity": 0.85},
        {"name": "Levi's 501 Original", "price_range": (59, 89), "popularity": 0.75},
        {"name": "Adidas Ultraboost 22", "price_range": (180, 220), "popularity": 0.7},
        {"name": "Patagonia Down Jacket", "price_range": (229, 329), "popularity": 0.5},
        {"name": "Uniqlo Heattech", "price_range": (19, 29), "popularity": 0.9}
    ],
    "Home": [
        {"name": "Dyson V15 Detect", "price_range": (749, 749), "popularity": 0.5},
        {"name": "Instant Pot Duo Plus", "price_range": (89, 119), "popularity": 0.8},
        {"name": "Nespresso Vertuo Next", "price_range": (199, 299), "popularity": 0.6},
        {"name": "Philips Hue Starter Kit", "price_range": (99, 199), "popularity": 0.4},
        {"name": "iRobot Roomba j7+", "price_range": (599, 899), "popularity": 0.3}
    ],
    "Luxury": [
        {"name": "Apple Watch Ultra 2", "price_range": (799, 899), "popularity": 0.3},
        {"name": "Hermès Birkin Bag", "price_range": (12000, 25000), "popularity": 0.05},
        {"name": "Rolex Submariner", "price_range": (8500, 12000), "popularity": 0.08},
        {"name": "Louis Vuitton Neverfull", "price_range": (1690, 2100), "popularity": 0.15}
    ]
}

REGIONS = [
    "California", "New York", "Texas", "Florida", "Illinois", 
    "Pennsylvania", "Ohio", "Georgia", "North Carolina", "Michigan"
]

PAYMENT_METHODS = {
    "Credit Card": 0.40,
    "PayPal": 0.25,
    "Apple Pay": 0.15,
    "Debit Card": 0.12,
    "Google Pay": 0.05,
    "Amazon Pay": 0.03
}

CHANNELS = {
    "Online": 0.55,
    "Mobile": 0.35,
    "Store": 0.10
}

def check_dependencies():
    """Check if required dependencies are installed"""
    try:
        import psycopg2
        return True
    except ImportError:
        print("❌ Required dependency missing: psycopg2")
        print("Install with: pip3 install psycopg2-binary")
        return False

def get_weighted_choice(choices_dict: Dict[str, float]) -> str:
    """Select item based on weighted probabilities"""
    choices = list(choices_dict.keys())
    weights = list(choices_dict.values())
    return random.choices(choices, weights=weights)[0]

def generate_premium_transaction() -> Dict[str, Any]:
    """Generate a high-impact transaction for demo effect"""
    # Black Friday / high-activity scenario
    category_weights = {"Electronics": 0.6, "Fashion": 0.25, "Home": 0.10, "Luxury": 0.05}
    category = get_weighted_choice(category_weights)
    
    products = PRODUCTS[category]
    # Bias toward popular products for demo effect
    product = random.choices(
        products, 
        weights=[p["popularity"] for p in products]
    )[0]
    
    # Add realistic price variance
    base_price = random.uniform(*product["price_range"])
    # Black Friday discount for some items
    if random.random() < 0.3:  # 30% chance of discount
        price = base_price * random.uniform(0.85, 0.95)  # 5-15% off
    else:
        price = base_price * random.uniform(0.98, 1.02)  # Small variance
    
    # Round to realistic pricing
    if price > 1000:
        price = round(price, -1)  # Round to nearest $10
    else:
        price = round(price, 2)
    
    return {
        "customer_name": random.choice(CUSTOMERS),
        "product_name": product["name"],
        "category": category,
        "region": random.choice(REGIONS),
        "amount": price,
        "payment_method": get_weighted_choice(PAYMENT_METHODS),
        "channel": get_weighted_choice(CHANNELS)
    }

def create_database_connection():
    """Create database connection with better error handling"""
    try:
        import psycopg2
        
        conn = psycopg2.connect(
            host=DEMO_CONFIG["db_config"]["host"],
            port=DEMO_CONFIG["db_config"]["port"],
            database=DEMO_CONFIG["db_config"]["database"],
            user=DEMO_CONFIG["db_config"]["user"],
            password=DEMO_CONFIG["db_config"]["password"],
            connect_timeout=10
        )
        return conn
    
    except psycopg2.OperationalError as e:
        if "Connection refused" in str(e):
            print("❌ Cannot connect to database. Is Podman running?")
            print("Try: podman compose -f docker-compose-podman.yml ps")
        else:
            print(f"❌ Database connection error: {e}")
        return None
    except Exception as e:
        print(f"❌ Unexpected error connecting to database: {e}")
        return None

def insert_transaction(cursor, transaction: Dict[str, Any]) -> bool:
    """Insert transaction with error handling"""
    try:
        query = """
        INSERT INTO demo.live_sales 
        (customer_name, product_name, category, region, amount, payment_method, channel, transaction_time)
        VALUES (%(customer_name)s, %(product_name)s, %(category)s, %(region)s, 
                %(amount)s, %(payment_method)s, %(channel)s, NOW())
        """
        cursor.execute(query, transaction)
        return True
    except Exception as e:
        print(f"⚠️  Failed to insert transaction: {e}")
        return False

def print_demo_header():
    """Print attractive demo header"""
    print("=" * 62)
    print("APACHE SUPERSET LIVE DEMO - PODMAN EDITION")
    print("Real-time E-commerce Analytics Simulation")
    print("=" * 62)
    print()
    print(f"Duration: {DEMO_CONFIG['duration_minutes']} minutes")
    print(f"Rate: {DEMO_CONFIG['transactions_per_second']} transactions/second")
    print(f"Scenario: Black Friday Sales Analytics")
    print()

def simulate_live_demo():
    """Main demo simulation with enhanced presentation features"""
    print_demo_header()
    
    # Check dependencies first
    if not check_dependencies():
        return
    
    # Create database connection
    print("Connecting to Superset database...")
    conn = create_database_connection()
    if not conn:
        return
    
    cursor = conn.cursor()
    print("Database connection established")
    print()
    
    # Demo simulation
    start_time = time.time()
    end_time = start_time + (DEMO_CONFIG["duration_minutes"] * 60)
    transaction_count = 0
    total_revenue = 0.0
    
    print("Starting live transaction simulation...")
    print("Open Superset dashboard to see real-time updates!")
    print("Dashboard: http://localhost:8088")
    print()
    
    try:
        while time.time() < end_time:
            # Generate transaction
            transaction = generate_premium_transaction()
            
            # Insert to database
            if insert_transaction(cursor, transaction):
                conn.commit()
                transaction_count += 1
                total_revenue += transaction["amount"]
                
                # Enhanced console output for presentation effect
                print(f"#{transaction_count:03d} | "
                      f"{transaction['customer_name']:<18} | "
                      f"{transaction['product_name']:<25} | "
                      f"${transaction['amount']:>8,.2f} | "
                      f"{transaction['region']:<12}")
                
                # Show milestone messages
                if transaction_count in [10, 25, 50, 100]:
                    print()
                    print(f"Milestone: {transaction_count} transactions completed!")
                    print(f"Total Revenue: ${total_revenue:,.2f}")
                    print(f"Average Order Value: ${total_revenue/transaction_count:,.2f}")
                    print()
                
                # Wait between transactions
                time.sleep(1 / DEMO_CONFIG["transactions_per_second"])
            else:
                print("⚠️  Transaction insert failed, retrying...")
                time.sleep(0.5)
    
    except KeyboardInterrupt:
        print("\nDemo simulation stopped by user")
    
    except Exception as e:
        print(f"\n❌ Simulation error: {e}")
    
    finally:
        # Cleanup and summary
        if cursor:
            cursor.close()
        if conn:
            conn.close()
        
        elapsed = time.time() - start_time
        print()
        print("=" * 52)
        print("DEMO SIMULATION COMPLETE!")
        print("=" * 52)
        print(f"Duration: {elapsed:.1f} seconds")
        print(f"Transactions: {transaction_count}")
        print(f"Total Revenue: ${total_revenue:,.2f}")
        if transaction_count > 0:
            print(f"Average Order: ${total_revenue/transaction_count:,.2f}")
            print(f"Rate: {transaction_count/elapsed:.1f} transactions/second")
        print()
        print("Check your Superset dashboards for live updates!")
        print("Dashboard: http://localhost:8088")

def main():
    """Main entry point"""
    print("APACHE SUPERSET LIVE DEMO SIMULATOR")
    print("=====================================")
    print("Optimized for Podman Containers")
    print()
    
    print("PRE-DEMO CHECKLIST:")
    print("- Podman containers running")
    print("- Superset accessible at http://localhost:8088")
    print("- Demo dashboards created")
    print("- Python dependencies installed")
    print()
    
    print("PRESENTATION TIPS:")
    print("• Keep this terminal visible during demo")
    print("• Show both terminal output AND dashboard updates")
    print("• Highlight the real-time nature of updates")
    print("• Point out specific transactions in dashboard")
    print()
    
    try:
        input("Press Enter to start the live demo simulation...")
        simulate_live_demo()
    except KeyboardInterrupt:
        print("\nDemo cancelled. Good luck with your presentation!")

if __name__ == "__main__":
    main()