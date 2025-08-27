-- Filter and aggregate events in real time
CREATE TABLE active_users AS
    SELECT user_id, COUNT(*) AS login_count
    FROM user_events
    WHERE event_type = 'login'
    GROUP BY user_id;
