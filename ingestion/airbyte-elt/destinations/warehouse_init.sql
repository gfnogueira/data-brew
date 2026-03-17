-- Data Warehouse Initialization
-- Schema setup for Airbyte raw data landing

-- Raw data schema (Airbyte lands data here)
CREATE SCHEMA IF NOT EXISTS raw_data;

-- Staging schema (for dbt transformations)
CREATE SCHEMA IF NOT EXISTS staging;

-- Analytics schema (for final models)
CREATE SCHEMA IF NOT EXISTS analytics;

-- Grant permissions
GRANT ALL PRIVILEGES ON SCHEMA raw_data TO warehouse_user;
GRANT ALL PRIVILEGES ON SCHEMA staging TO warehouse_user;
GRANT ALL PRIVILEGES ON SCHEMA analytics TO warehouse_user;

-- Create audit table for tracking syncs
CREATE TABLE IF NOT EXISTS raw_data._airbyte_sync_log (
    sync_id SERIAL PRIMARY KEY,
    source_name VARCHAR(100),
    stream_name VARCHAR(100),
    sync_started_at TIMESTAMP,
    sync_completed_at TIMESTAMP,
    records_synced INTEGER,
    status VARCHAR(20),
    error_message TEXT
);

-- Comment on schemas
COMMENT ON SCHEMA raw_data IS 'Raw data landing zone from Airbyte';
COMMENT ON SCHEMA staging IS 'Staging layer for data transformations';
COMMENT ON SCHEMA analytics IS 'Final analytics models';
