SELECT
  window_start,
  region,
  countMerge(events_count)                                                AS events,
  countIfMerge(error_count)                                               AS errors,
  round(countIfMerge(error_count) / nullIf(countMerge(events_count), 0), 4) AS error_rate
FROM realtime.metrics_1m
WHERE window_start >= now() - INTERVAL 30 MINUTE
GROUP BY window_start, region
HAVING errors > 0
ORDER BY window_start DESC, error_rate DESC;
