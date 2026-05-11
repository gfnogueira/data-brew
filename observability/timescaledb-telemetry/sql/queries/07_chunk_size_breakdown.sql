SELECT
  chunk_schema,
  chunk_name,
  range_start,
  range_end,
  pg_size_pretty(total_bytes)            AS total_size,
  pg_size_pretty(compressed_total_bytes) AS compressed_size,
  is_compressed
FROM chunks_detailed_size('telemetry_raw')
ORDER BY range_start DESC
LIMIT 20;
