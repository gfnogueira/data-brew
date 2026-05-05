SELECT
  region,
  countIfMerge(error_count)                                                  AS errors,
  countMerge(events_count)                                                   AS events,
  round(countIfMerge(error_count) / nullIf(countMerge(events_count), 0), 4)  AS error_rate
FROM realtime.metrics_1m
WHERE window_start >= now() - INTERVAL 5 MINUTE
GROUP BY region
HAVING error_rate > {max_rate:Float32}
ORDER BY error_rate DESC;
