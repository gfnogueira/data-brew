USE poc_lake;

SELECT table_name,
       count(*)              AS file_count,
       avg(file_size_bytes)  AS avg_file_bytes,
       sum(file_size_bytes)  AS total_bytes
FROM ducklake_table_info('poc_lake')
GROUP BY table_name
ORDER BY file_count DESC;

CALL ducklake_merge_adjacent_files('poc_lake', 'events',
  target_file_size => 134217728,
  schema           => 'main');

CALL ducklake_merge_adjacent_files('poc_lake', 'users',
  target_file_size => 67108864,
  schema           => 'main');

SELECT table_name,
       count(*)              AS file_count_after,
       avg(file_size_bytes)  AS avg_file_bytes_after
FROM ducklake_table_info('poc_lake')
GROUP BY table_name
ORDER BY file_count_after DESC;
