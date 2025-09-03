-- Count logins per user in 10-minute tumbling windows
CREATE TABLE user_login_windows AS
    SELECT user_id,
           WINDOWSTART AS window_start,
           WINDOWEND AS window_end,
           COUNT(*) AS login_count
    FROM user_events
    WINDOW TUMBLING (SIZE 10 MINUTES)
    WHERE event_type = 'login'
    GROUP BY user_id, WINDOWSTART, WINDOWEND;
