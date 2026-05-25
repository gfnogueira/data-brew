USE poc_lake;

ALTER TABLE users ADD COLUMN IF NOT EXISTS marketing_consent BOOLEAN DEFAULT false;

ALTER TABLE events ADD COLUMN IF NOT EXISTS request_id UUID;

UPDATE events
SET request_id = gen_random_uuid()
WHERE request_id IS NULL
  AND event_time >= now() - INTERVAL '30 minutes';

ALTER TABLE events ALTER amount TYPE DECIMAL(18, 4);

ALTER TABLE events RENAME COLUMN platform TO client_platform;

SELECT schema_version, column_count
FROM (
  SELECT max(schema_version) AS schema_version,
         count(DISTINCT column_name) AS column_count
  FROM ducklake_table_column_info('poc_lake', 'main', 'events')
);
