SELECT
  bucket,
  sum(samples)       AS samples,
  sum(bad_samples)   AS bad_samples
FROM telemetry_1m
WHERE bucket >= now() - INTERVAL '30 minutes'
GROUP BY bucket
ORDER BY bucket DESC
LIMIT 30;
