CREATE TABLE IF NOT EXISTS realtime.metrics_daily
(
  window_date     Date,
  region          LowCardinality(String),
  platform        LowCardinality(String),
  event_type      LowCardinality(String),
  events_count    AggregateFunction(count, UInt64),
  unique_users    AggregateFunction(uniq, String),
  revenue_total   AggregateFunction(sum, Decimal(18, 2)),
  error_count     AggregateFunction(countIf, UInt8)
)
ENGINE = AggregatingMergeTree
PARTITION BY toYYYYMM(window_date)
ORDER BY (window_date, region, platform, event_type)
TTL window_date + INTERVAL 365 DAY DELETE;

CREATE MATERIALIZED VIEW IF NOT EXISTS realtime.metrics_daily_mv
TO realtime.metrics_daily
AS
SELECT
  toDate(event_time)                                       AS window_date,
  region,
  platform,
  event_type,
  countState()                                             AS events_count,
  uniqState(user_id)                                       AS unique_users,
  sumState(toDecimal128(revenue_amount, 2))                AS revenue_total,
  countIfState(status_code >= 500)                         AS error_count
FROM realtime.user_events_raw
GROUP BY window_date, region, platform, event_type;
