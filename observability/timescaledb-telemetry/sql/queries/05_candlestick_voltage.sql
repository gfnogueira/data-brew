SELECT
  time_bucket('5 minutes', event_time) AS bucket,
  region,
  plant_id,
  first(measurement, event_time)       AS open_value,
  max(measurement)                     AS high_value,
  min(measurement)                     AS low_value,
  last(measurement, event_time)        AS close_value,
  count(*)                             AS samples
FROM telemetry_raw
WHERE sensor_type = 'voltage'
  AND event_time >= now() - INTERVAL '2 hours'
GROUP BY bucket, region, plant_id
ORDER BY bucket DESC, region, plant_id;
