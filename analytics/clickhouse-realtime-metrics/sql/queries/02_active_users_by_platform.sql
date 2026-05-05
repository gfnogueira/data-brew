SELECT
  window_start,
  platform,
  uniqMerge(unique_users)    AS active_users,
  countMerge(events_count)   AS events
FROM realtime.metrics_5m
WHERE window_start >= now() - INTERVAL 2 HOUR
GROUP BY window_start, platform
ORDER BY window_start DESC, active_users DESC;
