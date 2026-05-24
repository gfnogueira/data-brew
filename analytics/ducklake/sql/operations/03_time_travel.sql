USE poc_lake;

SELECT snapshot_id, snapshot_time, schema_version, changes
FROM ducklake_snapshots('poc_lake')
ORDER BY snapshot_id;

SELECT 'latest' AS source, count(*) AS events, sum(amount) AS revenue
FROM events
UNION ALL
SELECT 'snapshot_1', count(*), sum(amount)
FROM events AT (VERSION => 1)
UNION ALL
SELECT 'snapshot_2', count(*), sum(amount)
FROM events AT (VERSION => 2);

SELECT count(*) AS rows_one_hour_ago
FROM events AT (TIMESTAMP => now() - INTERVAL '1 hour');
