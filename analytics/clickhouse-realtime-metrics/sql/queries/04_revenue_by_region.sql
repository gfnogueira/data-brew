SELECT
  toStartOfHour(window_start)             AS hour_window,
  region,
  sumMerge(revenue_total)                 AS revenue,
  countMerge(events_count)                AS events,
  uniqMerge(unique_users)                 AS buyers
FROM realtime.metrics_5m
WHERE window_start >= now() - INTERVAL 6 HOUR
  AND event_type = 'purchase'
GROUP BY hour_window, region
ORDER BY hour_window DESC, revenue DESC;
