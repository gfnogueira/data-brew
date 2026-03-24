import json

from confluent_kafka import DeserializingConsumer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroDeserializer
from confluent_kafka.serialization import StringDeserializer

TOPIC = "customer-events"
SCHEMA_REGISTRY_URL = "http://localhost:8081"
BOOTSTRAP_SERVERS = "localhost:9092"
GROUP_ID = "customer-events-consumer"


def main():
    schema_registry_client = SchemaRegistryClient({"url": SCHEMA_REGISTRY_URL})
    avro_deserializer = AvroDeserializer(schema_registry_client)

    consumer_conf = {
        "bootstrap.servers": BOOTSTRAP_SERVERS,
        "key.deserializer": StringDeserializer("utf_8"),
        "value.deserializer": avro_deserializer,
        "group.id": GROUP_ID,
        "auto.offset.reset": "earliest",
    }

    consumer = DeserializingConsumer(consumer_conf)
    consumer.subscribe([TOPIC])

    print(f"Consuming from topic '{TOPIC}'...")
    try:
        while True:
            msg = consumer.poll(1.0)
            if msg is None:
                continue
            if msg.error():
                print(f"Consumer error: {msg.error()}")
                continue

            record = {
                "key": msg.key(),
                "value": msg.value(),
                "topic": msg.topic(),
                "partition": msg.partition(),
                "offset": msg.offset(),
            }
            print(json.dumps(record, indent=2))
    except KeyboardInterrupt:
        pass
    finally:
        consumer.close()


if __name__ == "__main__":
    main()
