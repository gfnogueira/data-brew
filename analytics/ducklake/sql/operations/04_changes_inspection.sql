USE poc_lake;

SELECT * FROM ducklake_table_changes('poc_lake', 'main', 'events', 1, 5)
ORDER BY snapshot_id, change_order
LIMIT 50;

SELECT table_name,
       sum(record_count)        AS records,
       count(*)                 AS data_files,
       sum(file_size_bytes)     AS bytes
FROM ducklake_table_info('poc_lake')
GROUP BY table_name
ORDER BY records DESC;
