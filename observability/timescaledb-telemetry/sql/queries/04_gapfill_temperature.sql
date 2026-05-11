SELECT
  time_bucket_gapfill('1 minute', event_time) AS bucket,
  region,
  locf(avg(measurement))                      AS avg_temp,
  interpolate(avg(measurement))               AS interp_temp
FROM telemetry_raw
WHERE sensor_type = 'temperature'
  AND event_time BETWEEN now() - INTERVAL '30 minutes' AND now()
GROUP BY bucket, region
ORDER BY bucket DESC, region;
