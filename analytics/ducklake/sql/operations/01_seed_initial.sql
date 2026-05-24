USE poc_lake;

INSERT INTO users
SELECT gen_random_uuid()::UUID                            AS user_id,
       'user' || range || '@example.com'                  AS email,
       now() - (random() * INTERVAL '30 days')            AS signup_at,
       (['BR','US','DE','FR','JP','AU'])[floor(random()*6)+1] AS country,
       (['free','starter','pro','enterprise'])[floor(random()*4)+1] AS tier
FROM range(0, 2000);

INSERT INTO events
SELECT gen_random_uuid()::UUID                                    AS event_id,
       now() - (random() * INTERVAL '24 hours')                   AS event_time,
       (SELECT user_id FROM users ORDER BY random() LIMIT 1)      AS user_id,
       (['page_view','click','add_to_cart','checkout','purchase'])[floor(random()*5)+1] AS event_type,
       (['web','ios','android'])[floor(random()*3)+1]             AS platform,
       (['us-east','us-west','eu-central','sa-east','ap-south'])[floor(random()*5)+1] AS region,
       CASE WHEN random() < 0.2 THEN round((random()*320)::DECIMAL(12,2), 2) ELSE 0::DECIMAL(12,2) END AS amount,
       CASE WHEN random() < 0.02 THEN 503 ELSE 200 END            AS status_code
FROM range(0, 20000);
