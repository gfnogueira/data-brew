import argparse
import json
import uuid
from datetime import datetime, timezone
from pathlib import Path

from confluent_kafka import SerializingProducer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroSerializer
from confluent_kafka.serialization import MessageField, SerializationContext, StringSerializer

TOPIC = "customer-events"
SCHEMA_REGISTRY_URL = "http://localhost:8081"
BOOTSTRAP_SERVERS = "localhost:9092"


def load_schema(version: str) -> str:
    schema_file = Path(__file__).resolve().parents[1] / "schemas" / f"customer_event_{version}.avsc"
    return schema_file.read_text(encoding="utf-8")


def delivery_report(err, msg):
    if err is not None:
        print(f"Delivery failed: {err}")
    else:
        print(f"Delivered key={msg.key()} to {msg.topic()}[{msg.partition()}]@{msg.offset()}")


def build_event(version: str) -> dict:
    base = {
        "event_id": str(uuid.uuid4()),
        "event_time": datetime.now(timezone.utc).isoformat(),
        "customer_id": f"CUS-{uuid.uuid4().hex[:8].upper()}",
        "customer_status": "active",
        "credit_score": 742,
    }
    if version == "v2":
        base["risk_tier"] = "low"
    return base


def main():
    parser = argparse.ArgumentParser(description="Produce Avro events to Kafka.")
    parser.add_argument("--version", choices=["v1", "v2"], default="v1")
    args = parser.parse_args()

    schema_registry_conf = {"url": SCHEMA_REGISTRY_URL}
    schema_registry_client = SchemaRegistryClient(schema_registry_conf)

    schema_str = load_schema(args.version)
    avro_serializer = AvroSerializer(schema_registry_client, schema_str)

    producer_conf = {
        "bootstrap.servers": BOOTSTRAP_SERVERS,
        "key.serializer": StringSerializer("utf_8"),
        "value.serializer": avro_serializer,
    }
    producer = SerializingProducer(producer_conf)

    payload = build_event(args.version)
    key = payload["customer_id"]
    producer.produce(
        topic=TOPIC,
        key=key,
        value=payload,
        on_delivery=delivery_report,
    )
    producer.flush()
    print("Produced payload:")
    print(json.dumps(payload, indent=2))


if __name__ == "__main__":
    main()
