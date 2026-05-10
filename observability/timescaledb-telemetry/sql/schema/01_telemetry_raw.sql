CREATE TABLE IF NOT EXISTS telemetry_raw (
  event_time    TIMESTAMPTZ      NOT NULL,
  device_id     TEXT             NOT NULL,
  sensor_type   TEXT             NOT NULL,
  region        TEXT             NOT NULL,
  plant_id      TEXT             NOT NULL,
  measurement   DOUBLE PRECISION NOT NULL,
  quality       SMALLINT         NOT NULL DEFAULT 2,
  status_code   SMALLINT         NOT NULL DEFAULT 0
);

SELECT create_hypertable(
  'telemetry_raw',
  'event_time',
  chunk_time_interval => INTERVAL '1 day',
  if_not_exists       => TRUE
);
