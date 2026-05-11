WITH series AS (
  SELECT event_time, measurement
  FROM telemetry_raw
  WHERE sensor_type = 'vibration'
    AND device_id = 'dev-0001'
    AND event_time >= now() - INTERVAL '6 hours'
)
SELECT time, value
FROM unnest((SELECT lttb(event_time, measurement, 200) FROM series));
