USE poc_lake;

UPDATE users SET tier = 'pro' WHERE tier = 'starter' AND random() < 0.3;

DELETE FROM events WHERE status_code >= 500;

INSERT INTO events
SELECT gen_random_uuid()::UUID                                    AS event_id,
       now() - (random() * INTERVAL '10 minutes')                 AS event_time,
       (SELECT user_id FROM users ORDER BY random() LIMIT 1)      AS user_id,
       'purchase'                                                 AS event_type,
       'web'                                                      AS platform,
       'eu-central'                                               AS region,
       round((random()*200 + 50)::DECIMAL(12,2), 2)               AS amount,
       200                                                        AS status_code
FROM range(0, 500);
