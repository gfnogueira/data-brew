SELECT
  region,
  arrayElement(quantilesTDigestMerge(0.95)(latency_quantiles), 1) AS p95_ms,
  countMerge(events_count)                                        AS events
FROM realtime.metrics_1m
WHERE window_start >= now() - INTERVAL 5 MINUTE
GROUP BY region
HAVING p95_ms > {threshold_ms:UInt32}
ORDER BY p95_ms DESC;
