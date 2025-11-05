#!/usr/bin/env python3
"""
Apache Pinot PoC - Batch Data Generator
Generates historical event data for batch ingestion testing
"""

import json
import random
import time
from datetime import datetime, timedelta
from pathlib import Path

# Configuration
OUTPUT_DIR = Path('batch-ingestion/data')
DAYS_OF_HISTORY = 30
EVENTS_PER_DAY = 10000

# Data generators
EVENT_TYPES = ['page_view', 'product_view', 'add_to_cart', 'purchase', 'search', 'login', 'logout']
CATEGORIES = ['electronics', 'clothing', 'books', 'home', 'sports', 'food', 'toys']
PLATFORMS = ['web', 'mobile_ios', 'mobile_android', 'tablet']
COUNTRIES = ['US', 'UK', 'CA', 'DE', 'FR', 'JP', 'BR', 'IN']
CITIES = {
    'US': ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'],
    'UK': ['London', 'Manchester', 'Birmingham', 'Leeds', 'Glasgow'],
    'CA': ['Toronto', 'Vancouver', 'Montreal', 'Calgary', 'Ottawa'],
    'DE': ['Berlin', 'Munich', 'Hamburg', 'Frankfurt', 'Cologne'],
    'FR': ['Paris', 'Marseille', 'Lyon', 'Toulouse', 'Nice'],
    'JP': ['Tokyo', 'Osaka', 'Yokohama', 'Nagoya', 'Sapporo'],
    'BR': ['São Paulo', 'Rio de Janeiro', 'Brasília', 'Salvador', 'Fortaleza'],
    'IN': ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai']
}
DEVICE_TYPES = ['desktop', 'mobile', 'tablet']

def generate_event(base_timestamp):
    """Generate a single event record"""
    country = random.choice(COUNTRIES)
    event_type = random.choice(EVENT_TYPES)
    
    event = {
        'event_id': f'evt_{base_timestamp}_{random.randint(1000, 9999)}',
        'user_id': f'user_{random.randint(1, 10000)}',
        'event_type': event_type,
        'product_id': f'prod_{random.randint(1, 1000)}',
        'category': random.choice(CATEGORIES),
        'platform': random.choice(PLATFORMS),
        'country': country,
        'city': random.choice(CITIES[country]),
        'device_type': random.choice(DEVICE_TYPES),
        'session_id': f'sess_{random.randint(100000, 999999)}',
        'event_time': base_timestamp
    }
    
    if event_type == 'purchase':
        event['amount'] = round(random.uniform(10.0, 500.0), 2)
        event['quantity'] = random.randint(1, 5)
        event['duration_seconds'] = 0
    elif event_type == 'product_view':
        event['amount'] = 0.0
        event['quantity'] = 0
        event['duration_seconds'] = random.randint(5, 300)
    else:
        event['amount'] = 0.0
        event['quantity'] = 0
        event['duration_seconds'] = random.randint(1, 60)
    
    return event

def generate_batch_data():
    """Generate historical batch data"""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    print(f"Generating {DAYS_OF_HISTORY} days of historical data...")
    print(f"Events per day: {EVENTS_PER_DAY}")
    
    end_date = datetime.now()
    start_date = end_date - timedelta(days=DAYS_OF_HISTORY)
    
    total_events = 0
    
    for day_offset in range(DAYS_OF_HISTORY):
        current_date = start_date + timedelta(days=day_offset)
        day_str = current_date.strftime('%Y%m%d')
        
        output_file = OUTPUT_DIR / f'events_{day_str}.json'
        
        with open(output_file, 'w') as f:
            for _ in range(EVENTS_PER_DAY):
                timestamp = int(current_date.timestamp() * 1000) + random.randint(0, 86400000)
                event = generate_event(timestamp)
                f.write(json.dumps(event) + '\n')
                total_events += 1
        
        print(f"Generated {day_str}: {EVENTS_PER_DAY} events")
    
    print(f"\nTotal events generated: {total_events}")
    print(f"Output directory: {OUTPUT_DIR}")

if __name__ == '__main__':
    generate_batch_data()