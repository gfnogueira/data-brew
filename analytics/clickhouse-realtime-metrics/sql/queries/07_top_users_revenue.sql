SELECT
  user_id,
  count()                       AS purchases,
  sum(revenue_amount)           AS revenue,
  max(event_time)               AS last_purchase_at
FROM realtime.user_events_raw
WHERE event_time >= now() - INTERVAL 1 HOUR
  AND event_type = 'purchase'
GROUP BY user_id
ORDER BY revenue DESC
LIMIT 25;
