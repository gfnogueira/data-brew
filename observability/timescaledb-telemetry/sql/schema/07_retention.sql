SELECT add_retention_policy('telemetry_raw', INTERVAL '30 days',  if_not_exists => TRUE);
SELECT add_retention_policy('telemetry_1m',  INTERVAL '90 days',  if_not_exists => TRUE);
SELECT add_retention_policy('telemetry_1h',  INTERVAL '365 days', if_not_exists => TRUE);
