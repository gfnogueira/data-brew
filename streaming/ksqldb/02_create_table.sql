-- Create a KSQLDB table for counting events per user
CREATE TABLE user_event_counts AS
    SELECT user_id, COUNT(*) AS event_count
    FROM user_events
    GROUP BY user_id;
