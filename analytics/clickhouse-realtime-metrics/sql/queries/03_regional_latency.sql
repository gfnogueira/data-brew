SELECT
  region,
  countMerge(events_count)                                   AS events,
  arrayElement(quantilesTDigestMerge(0.5, 0.95, 0.99)(latency_quantiles), 1) AS p50_ms,
  arrayElement(quantilesTDigestMerge(0.5, 0.95, 0.99)(latency_quantiles), 2) AS p95_ms,
  arrayElement(quantilesTDigestMerge(0.5, 0.95, 0.99)(latency_quantiles), 3) AS p99_ms
FROM realtime.metrics_1m
WHERE window_start >= now() - INTERVAL 15 MINUTE
GROUP BY region
ORDER BY p95_ms DESC;
