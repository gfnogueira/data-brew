CREATE TABLE IF NOT EXISTS realtime.user_events_raw
(
  event_id        UUID,
  event_time      DateTime64(3),
  event_date      Date  MATERIALIZED toDate(event_time),
  ingestion_time  DateTime64(3) DEFAULT now64(3),
  user_id         String,
  session_id      String,
  event_type      LowCardinality(String),
  platform        LowCardinality(String),
  region          LowCardinality(String),
  device_type     LowCardinality(String),
  revenue_amount  Decimal(12, 2) DEFAULT 0,
  latency_ms      UInt32,
  status_code     UInt16
)
ENGINE = MergeTree
PARTITION BY toYYYYMMDD(event_date)
ORDER BY (event_date, region, platform, event_type, user_id, event_time)
TTL event_date + INTERVAL 7 DAY DELETE
SETTINGS index_granularity = 8192,
         ttl_only_drop_parts = 1;
