SELECT add_continuous_aggregate_policy(
  'telemetry_1m',
  start_offset      => INTERVAL '30 minutes',
  end_offset        => INTERVAL '1 minute',
  schedule_interval => INTERVAL '30 seconds',
  if_not_exists     => TRUE
);

SELECT add_continuous_aggregate_policy(
  'telemetry_1h',
  start_offset      => INTERVAL '6 hours',
  end_offset        => INTERVAL '5 minutes',
  schedule_interval => INTERVAL '5 minutes',
  if_not_exists     => TRUE
);
