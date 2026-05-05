WITH
  (SELECT sumMerge(revenue_total) FROM realtime.metrics_5m
   WHERE window_start >= now() - INTERVAL 15 MINUTE
     AND event_type = 'purchase')                                  AS recent_revenue,
  (SELECT sumMerge(revenue_total) FROM realtime.metrics_5m
   WHERE window_start >= now() - INTERVAL 75 MINUTE
     AND window_start <  now() - INTERVAL 15 MINUTE
     AND event_type = 'purchase') / 4                              AS baseline_revenue
SELECT
  recent_revenue,
  baseline_revenue,
  round(recent_revenue / nullIf(baseline_revenue, 0), 4)           AS ratio,
  if(recent_revenue < baseline_revenue * {min_ratio:Float32}, 1, 0) AS triggered;
