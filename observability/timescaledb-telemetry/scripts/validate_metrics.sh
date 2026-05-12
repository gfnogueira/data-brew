#!/usr/bin/env bash
set -euo pipefail

PSQL=(docker compose exec -T timescaledb psql
  -U "${POSTGRES_USER:-telemetry_user}"
  -d "${POSTGRES_DB:-telemetry}"
  -v ON_ERROR_STOP=1)

run() {
  local title="$1"
  shift
  echo "==> ${title}"
  "${PSQL[@]}" "$@"
  echo
}

run "Raw event volume in the last 30 minutes" \
  -c "SELECT count(*) AS events FROM telemetry_raw WHERE event_time >= now() - INTERVAL '30 minutes'"

run "Aggregation freshness lag (seconds)" \
  -c "
    WITH raw_max AS (SELECT max(event_time) AS t FROM telemetry_raw),
         agg_max AS (SELECT max(bucket)     AS t FROM telemetry_1m)
    SELECT raw_max.t                                   AS raw_max,
           agg_max.t                                   AS agg_max,
           extract(epoch FROM raw_max.t - agg_max.t)::int AS lag_seconds
    FROM raw_max, agg_max
  "

run "Recent 1-minute aggregation windows" \
  -c "
    SELECT bucket, sum(samples) AS samples, sum(bad_samples) AS bad
    FROM telemetry_1m
    WHERE bucket >= now() - INTERVAL '15 minutes'
    GROUP BY bucket
    ORDER BY bucket DESC
    LIMIT 10
  "

run "Cross-tier consistency (1h vs sum of 1m, last 2 hours)" \
  -c "
    WITH a AS (SELECT sum(samples) AS s FROM telemetry_1m WHERE bucket >= now() - INTERVAL '2 hours'),
         b AS (SELECT sum(samples) AS s FROM telemetry_1h WHERE bucket >= now() - INTERVAL '2 hours')
    SELECT a.s AS samples_1m, b.s AS samples_1h, abs(a.s - b.s) AS delta FROM a, b
  "

run "Compression effectiveness on aged chunks" \
  -c "
    SELECT count(*) FILTER (WHERE is_compressed) AS compressed_chunks,
           count(*)                              AS total_chunks,
           pg_size_pretty(sum(total_bytes))       AS total_size,
           pg_size_pretty(sum(compressed_total_bytes)) AS compressed_size
    FROM chunks_detailed_size('telemetry_raw')
  "

echo "Validation completed."
