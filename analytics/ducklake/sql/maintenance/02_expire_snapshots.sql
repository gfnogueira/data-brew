USE poc_lake;

SELECT count(*) AS snapshots_before FROM ducklake_snapshots('poc_lake');

CALL ducklake_expire_snapshots('poc_lake',
  older_than => now() - INTERVAL '7 days');

CALL ducklake_expire_snapshots('poc_lake',
  versions       => 50,
  keep_latest    => true);

SELECT count(*) AS snapshots_after FROM ducklake_snapshots('poc_lake');
