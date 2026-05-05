WITH
  (SELECT countMerge(events_count) FROM realtime.metrics_1m
   WHERE window_start >= now() - INTERVAL 5 MINUTE)        AS recent_events,
  (SELECT countMerge(events_count) FROM realtime.metrics_1m
   WHERE window_start >= now() - INTERVAL 35 MINUTE
     AND window_start <  now() - INTERVAL 5 MINUTE) / 6     AS baseline_events
SELECT
  recent_events,
  baseline_events,
  round(recent_events / nullIf(baseline_events, 0), 4)      AS ratio,
  if(recent_events < baseline_events * {min_ratio:Float32}, 1, 0) AS triggered;
