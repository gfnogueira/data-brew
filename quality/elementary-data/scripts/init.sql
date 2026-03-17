-- Database initialization script
-- Creates schemas for dbt layers

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS marts;
CREATE SCHEMA IF NOT EXISTS elementary;

-- Grant permissions
GRANT ALL PRIVILEGES ON SCHEMA raw TO dbt_user;
GRANT ALL PRIVILEGES ON SCHEMA staging TO dbt_user;
GRANT ALL PRIVILEGES ON SCHEMA marts TO dbt_user;
GRANT ALL PRIVILEGES ON SCHEMA elementary TO dbt_user;
