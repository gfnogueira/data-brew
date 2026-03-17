-- Create a KSQLDB stream from a Kafka topic
CREATE STREAM user_events (
    user_id VARCHAR,
    event_type VARCHAR,
    event_time BIGINT
) WITH (
    KAFKA_TOPIC='user_events',
    VALUE_FORMAT='JSON'
);
