#!/usr/bin/env python3
"""
Apache Pinot PoC - Event Data Generator
Generates event data and publishes to Kafka
"""

import json
import random
import time
from datetime import datetime
from kafka import KafkaProducer
from kafka.errors import NoBrokersAvailable

# Configuration
KAFKA_BOOTSTRAP_SERVERS = 'localhost:9092'
KAFKA_TOPIC = 'events-topic'
EVENTS_PER_SECOND = 10

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

def generate_event():
    """Generate a single event record"""
    country = random.choice(COUNTRIES)
    event_type = random.choice(EVENT_TYPES)
    
    event = {
        'event_id': f'evt_{int(time.time() * 1000)}_{random.randint(1000, 9999)}',
        'user_id': f'user_{random.randint(1, 10000)}',
        'event_type': event_type,
        'product_id': f'prod_{random.randint(1, 1000)}',
        'category': random.choice(CATEGORIES),
        'platform': random.choice(PLATFORMS),
        'country': country,
        'city': random.choice(CITIES[country]),
        'device_type': random.choice(DEVICE_TYPES),
        'session_id': f'sess_{random.randint(100000, 999999)}',
        'event_time': int(time.time() * 1000)
    }
    
    # Add metrics based on event type
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

def create_kafka_producer():
    """Create Kafka producer with retry logic"""
    max_retries = 10
    retry_delay = 5
    
    for attempt in range(max_retries):
        try:
            producer = KafkaProducer(
                bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
                value_serializer=lambda v: json.dumps(v).encode('utf-8'),
                acks='all',
                retries=3
            )
            print(f"Connected to Kafka at {KAFKA_BOOTSTRAP_SERVERS}")
            return producer
        except NoBrokersAvailable:
            if attempt < max_retries - 1:
                print(f"Kafka not available. Retrying in {retry_delay} seconds... (Attempt {attempt + 1}/{max_retries})")
                time.sleep(retry_delay)
            else:
                raise

def main():
    """Data generation loop"""
    print("Starting event data generator...")
    print(f"Target: {EVENTS_PER_SECOND} events/second")
    print(f"Publishing to topic: {KAFKA_TOPIC}")
    
    producer = create_kafka_producer()
    
    events_sent = 0
    start_time = time.time()
    
    try:
        while True:
            event = generate_event()
            producer.send(KAFKA_TOPIC, value=event)
            events_sent += 1
            
            # Log progress every 100 events
            if events_sent % 100 == 0:
                elapsed = time.time() - start_time
                rate = events_sent / elapsed if elapsed > 0 else 0
                print(f"Sent {events_sent} events (Rate: {rate:.2f} events/sec)")
            
            # Control rate
            time.sleep(1.0 / EVENTS_PER_SECOND)
            
    except KeyboardInterrupt:
        print("\nShutting down gracefully...")
    finally:
        producer.flush()
        producer.close()
        elapsed = time.time() - start_time
        print(f"\nTotal events sent: {events_sent}")
        print(f"Total time: {elapsed:.2f} seconds")
        print(f"Average rate: {events_sent / elapsed:.2f} events/sec")

if __name__ == '__main__':
    main()