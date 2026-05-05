WITH session_events AS
(
  SELECT
    session_id,
    groupArray(event_type) AS path
  FROM realtime.user_events_raw
  WHERE event_time >= now() - INTERVAL 30 MINUTE
  GROUP BY session_id
)
SELECT
  countIf(has(path, 'page_view'))                                            AS visited,
  countIf(has(path, 'add_to_cart'))                                          AS added_to_cart,
  countIf(has(path, 'checkout'))                                             AS started_checkout,
  countIf(has(path, 'purchase'))                                             AS purchased,
  round(countIf(has(path, 'purchase')) / nullIf(countIf(has(path, 'page_view')), 0), 4) AS conversion_rate
FROM session_events;
