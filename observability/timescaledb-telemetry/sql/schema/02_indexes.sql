CREATE INDEX IF NOT EXISTS idx_telemetry_device_time
  ON telemetry_raw (device_id, event_time DESC);

CREATE INDEX IF NOT EXISTS idx_telemetry_region_plant_time
  ON telemetry_raw (region, plant_id, event_time DESC);

CREATE INDEX IF NOT EXISTS idx_telemetry_sensor_time
  ON telemetry_raw (sensor_type, event_time DESC);

CREATE INDEX IF NOT EXISTS idx_telemetry_quality_time
  ON telemetry_raw (event_time DESC)
  WHERE quality < 2;
