USE poc_lake;

CALL ducklake_cleanup_old_files('poc_lake',
  older_than => now() - INTERVAL '24 hours',
  dry_run    => true);

CALL ducklake_cleanup_old_files('poc_lake',
  older_than => now() - INTERVAL '24 hours',
  dry_run    => false);

SELECT count(*)                 AS active_files,
       sum(file_size_bytes)     AS total_bytes
FROM ducklake_table_info('poc_lake');
