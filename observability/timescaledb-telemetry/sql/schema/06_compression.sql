ALTER TABLE telemetry_raw SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'region, plant_id, sensor_type',
  timescaledb.compress_orderby   = 'event_time DESC, device_id'
);

SELECT add_compression_policy(
  'telemetry_raw',
  compress_after => INTERVAL '3 days',
  if_not_exists  => TRUE
);
