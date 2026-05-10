CREATE MATERIALIZED VIEW IF NOT EXISTS telemetry_1m
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 minute', event_time)             AS bucket,
  region,
  plant_id,
  sensor_type,
  count(*)                                        AS samples,
  count(*) FILTER (WHERE quality < 2)             AS bad_samples,
  avg(measurement)                                AS avg_value,
  min(measurement)                                AS min_value,
  max(measurement)                                AS max_value,
  stddev_samp(measurement)                        AS stddev_value,
  percentile_agg(measurement)                     AS measurement_percentiles
FROM telemetry_raw
GROUP BY bucket, region, plant_id, sensor_type
WITH NO DATA;

CREATE INDEX IF NOT EXISTS idx_telemetry_1m_dimension_bucket
  ON telemetry_1m (region, plant_id, sensor_type, bucket DESC);
