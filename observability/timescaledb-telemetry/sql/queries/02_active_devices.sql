SELECT
  time_bucket('5 minutes', event_time) AS bucket,
  region,
  count(DISTINCT device_id)            AS active_devices,
  count(*)                             AS samples
FROM telemetry_raw
WHERE event_time >= now() - INTERVAL '1 hour'
GROUP BY bucket, region
ORDER BY bucket DESC, active_devices DESC;
