SELECT
  region,
  plant_id,
  sensor_type,
  sum(samples)                                                         AS samples,
  approx_percentile(0.50, rollup(measurement_percentiles))              AS p50,
  approx_percentile(0.95, rollup(measurement_percentiles))              AS p95,
  approx_percentile(0.99, rollup(measurement_percentiles))              AS p99
FROM telemetry_1m
WHERE bucket >= now() - INTERVAL '15 minutes'
GROUP BY region, plant_id, sensor_type
ORDER BY p95 DESC
LIMIT 50;
