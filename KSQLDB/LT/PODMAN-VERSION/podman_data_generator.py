#!/usr/bin/env python3
"""
Data Generator for ksqlDB Demo with Podman
Simulates real-time e-commerce transactions
"""

import json
import random
import time
from datetime import datetime, timedelta
from dataclasses import dataclass, asdict
import threading
import sys
from kafka import KafkaProducer

@dataclass
class Transaction:
    """E-commerce transaction structure"""
    transaction_id: str
    user_id: str
    product_name: str
    category: str
    amount: float
    timestamp: str
    payment_method: str
    state: str
    city: str
    device_type: str
    ip_address: str
    suspicious: bool
    alert_message: str = ""

class TransactionGenerator:
    def __init__(self):
        # Sample data for generating realistic transactions
        self.products = [
            ("iPhone 15 Pro", "Electronics"), ("Samsung Galaxy S24", "Electronics"),
            ("MacBook Pro", "Electronics"), ("Dell XPS", "Electronics"),
            ("Nike Air Max", "Fashion"), ("Adidas Ultraboost", "Fashion"),
            ("Levi's Jeans", "Fashion"), ("Zara Jacket", "Fashion"),
            ("Vitamins", "Health"), ("Protein Whey", "Health"),
            ("Python Book", "Books"), ("AI Book", "Books"),
            ("Premium Coffee", "Food"), ("Acai Bowl", "Food")
        ]
        
        self.payment_methods = ["credit_card", "debit_card", "pix", "paypal", "crypto"]
        
        self.us_states = [
            ("CA", "Los Angeles"), ("NY", "New York"), ("TX", "Houston"),
            ("FL", "Miami"), ("IL", "Chicago"), ("WA", "Seattle"),
            ("MA", "Boston"), ("CO", "Denver"), ("GA", "Atlanta"), ("OR", "Portland")
        ]
        
        self.device_types = ["mobile", "desktop", "tablet"]
        
        # Fraud detection configurations
        self.high_risk_ips = ["192.168.100.666", "10.0.0.999", "172.16.255.255"]
        self.suspicious_amounts = [(5000, 10000), (15000, 25000)]
        
        # Setup Kafka producer
        self.setup_kafka_producer()
    
    def setup_kafka_producer(self):
        """Configure Kafka producer"""
        try:
            self.producer = KafkaProducer(
                bootstrap_servers=['localhost:9092'],
                value_serializer=lambda x: json.dumps(x, ensure_ascii=False).encode('utf-8'),
                key_serializer=lambda x: x.encode('utf-8') if x else None
            )
            print("Connected to Kafka (Podman)")
        except Exception as e:
            print(f"Error connecting to Kafka: {e}")
            sys.exit(1)
    
    def generate_ip(self, suspicious: bool = False) -> str:
        """Generate IP address (suspicious or normal)"""
        if suspicious and random.random() < 0.3:
            return random.choice(self.high_risk_ips)
        
        return f"{random.randint(1,255)}.{random.randint(1,255)}.{random.randint(1,255)}.{random.randint(1,255)}"
    
    def detect_fraud(self, transaction: Transaction) -> bool:
        """Simple fraud detection algorithm"""
        fraud_indicators = 0
        
        # Very high amount
        if transaction.amount > 5000:
            fraud_indicators += 1
        
        # Suspicious IP
        if transaction.ip_address in self.high_risk_ips:
            fraud_indicators += 2
            
        # Payment method + suspicious time
        if transaction.payment_method == "crypto" and datetime.now().hour < 6:
            fraud_indicators += 1
            
        # Multiple risk factors
        if (transaction.amount > 2000 and 
            transaction.device_type == "mobile" and 
            transaction.payment_method in ["crypto", "paypal"]):
            fraud_indicators += 1
        
        return fraud_indicators >= 2
    
    def generate_transaction(self) -> Transaction:
        """Generate a single transaction"""
        # Basic data
        transaction_id = f"TXN{random.randint(100000, 999999)}"
        user_id = f"USER{random.randint(1000, 9999)}"
        product_name, category = random.choice(self.products)
        
        # Amount based on category
        if category == "Electronics":
            amount = round(random.uniform(800, 8000), 2)
        elif category == "Fashion":
            amount = round(random.uniform(50, 500), 2)
        elif category == "Health":
            amount = round(random.uniform(30, 300), 2)
        else:
            amount = round(random.uniform(20, 200), 2)
        
        # Occasionally generate suspicious amounts
        if random.random() < 0.15:  # 15% chance
            amount = round(random.uniform(5000, 20000), 2)
        
        # Other fields
        timestamp = datetime.now().isoformat()
        payment_method = random.choice(self.payment_methods)
        state_code, city = random.choice(self.us_states)
        device_type = random.choice(self.device_types)
        
        # Create initial transaction
        transaction = Transaction(
            transaction_id=transaction_id,
            user_id=user_id,
            product_name=product_name,
            category=category,
            amount=amount,
            timestamp=timestamp,
            payment_method=payment_method,
            state=state_code,
            city=city,
            device_type=device_type,
            ip_address="",  # Will be filled below
            suspicious=False  # Will be calculated below
        )
        
        # Detect fraud
        transaction.suspicious = self.detect_fraud(transaction)
        transaction.ip_address = self.generate_ip(transaction.suspicious)
        
        # Add alert message if suspicious
        if transaction.suspicious:
            transaction.alert_message = f"FRAUD DETECTED! Amount: ${amount:.2f}, IP: {transaction.ip_address}"
        
        return transaction
    
    def send_transaction(self, transaction: Transaction):
        """Send transaction to Kafka"""
        try:
            # Convert to dict
            transaction_dict = asdict(transaction)
            
            # Send to Kafka
            future = self.producer.send(
                'ecommerce_transactions',
                key=transaction.transaction_id,
                value=transaction_dict
            )
            
            # Wait for confirmation
            future.get(timeout=10)
            
            # Log transaction
            fraud_indicator = "SUSPICIOUS" if transaction.suspicious else "Normal"
            print(f"{fraud_indicator} | {transaction.transaction_id} | {transaction.user_id} | "
                  f"{transaction.product_name} | ${transaction.amount:.2f} | {transaction.state}")
            
            if transaction.suspicious:
                print(f"    └─ {transaction.alert_message}")
            
        except Exception as e:
            print(f"Error sending transaction: {e}")
    
    def run_generator(self, duration_minutes: int = 10, transactions_per_minute: int = 12):
        """Run generator for a specific period"""
        print(f"STARTING DATA GENERATOR - PODMAN VERSION")
        print(f"Duration: {duration_minutes} minutes")
        print(f"Rate: {transactions_per_minute} transactions/minute")
        print(f"Kafka Topic: ecommerce_transactions")
        print("=" * 60)
        
        interval = 60 / transactions_per_minute  # Interval in seconds
        end_time = datetime.now() + timedelta(minutes=duration_minutes)
        
        transaction_count = 0
        suspicious_count = 0
        
        try:
            while datetime.now() < end_time:
                # Generate and send transaction
                transaction = self.generate_transaction()
                self.send_transaction(transaction)
                
                transaction_count += 1
                if transaction.suspicious:
                    suspicious_count += 1
                
                # Statistics every 50 transactions
                if transaction_count % 50 == 0:
                    fraud_rate = (suspicious_count / transaction_count) * 100
                    print(f"\nSTATISTICS: {transaction_count} transactions | "
                          f"{suspicious_count} suspicious ({fraud_rate:.1f}%)\n")
                
                # Wait for next transaction
                time.sleep(interval)
                
        except KeyboardInterrupt:
            print(f"\nGenerator interrupted by user")
        
        finally:
            # Final statistics
            fraud_rate = (suspicious_count / transaction_count) * 100 if transaction_count > 0 else 0
            print(f"\nFINAL REPORT:")
            print(f"   • Total transactions: {transaction_count}")
            print(f"   • Suspicious transactions: {suspicious_count}")
            print(f"   • Fraud rate: {fraud_rate:.1f}%")
            print(f"   • Actual duration: {datetime.now().strftime('%H:%M:%S')}")
            
            self.producer.close()
            print("Generator finished - Podman version")

def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Usage: python3 podman_data_generator.py <minutes> [transactions_per_minute]")
        print("Example: python3 podman_data_generator.py 5 15")
        sys.exit(1)
    
    try:
        duration = int(sys.argv[1])
        rate = int(sys.argv[2]) if len(sys.argv) > 2 else 12
        
        generator = TransactionGenerator()
        generator.run_generator(duration, rate)
        
    except ValueError:
        print("ERROR: Arguments must be integers")
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
