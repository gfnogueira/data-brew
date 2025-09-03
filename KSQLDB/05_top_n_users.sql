-- Live leaderboard: top 3 users by event count
CREATE TABLE top_users AS
    SELECT user_id, event_count
    FROM (
        SELECT user_id, COUNT(*) AS event_count
        FROM user_events
        GROUP BY user_id
    )
    ORDER BY event_count DESC
    LIMIT 3;
