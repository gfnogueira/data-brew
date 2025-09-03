-- Detect suspicious activity: multiple purchases by same user in 1 minute
CREATE TABLE suspicious_purchases AS
    SELECT user_id,
           COUNT(*) AS purchase_count,
           WINDOWSTART AS window_start,
           WINDOWEND AS window_end
    FROM user_events
    WINDOW TUMBLING (SIZE 1 MINUTES)
    WHERE event_type = 'purchase'
    GROUP BY user_id, WINDOWSTART, WINDOWEND
    HAVING COUNT(*) > 2;
