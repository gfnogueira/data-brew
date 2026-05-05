SELECT
  window_start,
  countMerge(events_count)        AS events,
  uniqMerge(unique_users)         AS active_users,
  uniqMerge(unique_sessions)      AS active_sessions
FROM realtime.metrics_1m
WHERE window_start >= now() - INTERVAL 30 MINUTE
GROUP BY window_start
ORDER BY window_start DESC
LIMIT 30;
