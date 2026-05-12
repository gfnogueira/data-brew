#!/usr/bin/env bash
set -euo pipefail

PSQL=(docker compose exec -T timescaledb psql
  -U "${POSTGRES_USER:-telemetry_user}"
  -d "${POSTGRES_DB:-telemetry}"
  -v ON_ERROR_STOP=1)

section() {
  echo "==> $1"
  shift
  "${PSQL[@]}" "$@"
  echo
}

section "Server identity and extension versions" \
  -c "
    SELECT version() AS pg_version,
           current_setting('shared_preload_libraries') AS preloaded,
           extversion AS timescaledb_version
    FROM pg_extension
    WHERE extname = 'timescaledb'
  "

section "Hypertable inventory" \
  -c "
    SELECT hypertable_schema, hypertable_name, num_dimensions, num_chunks,
           pg_size_pretty(hypertable_size(format('%I.%I', hypertable_schema, hypertable_name)::regclass)) AS size
    FROM timescaledb_information.hypertables
  "

section "Continuous aggregates" \
  -c "
    SELECT view_name, materialization_hypertable_name, materialized_only, finalized
    FROM timescaledb_information.continuous_aggregates
  "

section "Background jobs and last run status" \
  -c "
    SELECT j.job_id,
           j.application_name,
           j.proc_name,
           s.last_run_status,
           s.last_successful_finish,
           s.total_runs,
           s.total_failures
    FROM timescaledb_information.jobs j
    LEFT JOIN timescaledb_information.job_stats s USING (job_id)
    ORDER BY j.job_id
  "

section "Compression policy status" \
  -c "
    SELECT hypertable_name,
           compression_enabled,
           compressed_chunk_count,
           uncompressed_chunk_count,
           pg_size_pretty(after_compression_total_bytes) AS compressed_size,
           pg_size_pretty(before_compression_total_bytes) AS uncompressed_size
    FROM timescaledb_information.hypertable_compression_settings hcs
    JOIN hypertable_compression_stats() hstats USING (hypertable_name)
  " || true

echo "Health check completed."
