CREATE TABLE IF NOT EXISTS realtime.metrics_5m
(
  window_start      DateTime,
  region            LowCardinality(String),
  platform          LowCardinality(String),
  event_type        LowCardinality(String),
  events_count      AggregateFunction(count, UInt64),
  unique_users      AggregateFunction(uniq, String),
  unique_sessions   AggregateFunction(uniq, String),
  revenue_total     AggregateFunction(sum, Decimal(18, 2)),
  latency_quantiles AggregateFunction(quantilesTDigest(0.5, 0.95, 0.99), UInt32),
  error_count       AggregateFunction(countIf, UInt8)
)
ENGINE = AggregatingMergeTree
PARTITION BY toYYYYMM(window_start)
ORDER BY (window_start, region, platform, event_type)
TTL window_start + INTERVAL 30 DAY DELETE;

CREATE MATERIALIZED VIEW IF NOT EXISTS realtime.metrics_5m_mv
TO realtime.metrics_5m
AS
SELECT
  toStartOfFiveMinutes(event_time)                         AS window_start,
  region,
  platform,
  event_type,
  countState()                                             AS events_count,
  uniqState(user_id)                                       AS unique_users,
  uniqState(session_id)                                    AS unique_sessions,
  sumState(toDecimal128(revenue_amount, 2))                AS revenue_total,
  quantilesTDigestState(0.5, 0.95, 0.99)(latency_ms)       AS latency_quantiles,
  countIfState(status_code >= 500)                         AS error_count
FROM realtime.user_events_raw
GROUP BY window_start, region, platform, event_type;
