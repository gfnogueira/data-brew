import psycopg

from .config import PostgresConfig, postgres_config

INSERT_COLUMNS = (
    "event_time",
    "device_id",
    "sensor_type",
    "region",
    "plant_id",
    "measurement",
    "quality",
    "status_code",
)


def connect(config: PostgresConfig | None = None) -> psycopg.Connection:
    config = config or postgres_config()
    conn = psycopg.connect(config.dsn(), autocommit=False)
    return conn


def copy_events(conn: psycopg.Connection, rows) -> int:
    columns = ", ".join(INSERT_COLUMNS)
    copy_sql = f"COPY telemetry_raw ({columns}) FROM STDIN"
    inserted = 0
    with conn.cursor() as cur, cur.copy(copy_sql) as copy:
        for row in rows:
            copy.write_row(row)
            inserted += 1
    conn.commit()
    return inserted


def insert_batch(conn: psycopg.Connection, rows) -> int:
    columns = ", ".join(INSERT_COLUMNS)
    placeholders = ", ".join(["%s"] * len(INSERT_COLUMNS))
    sql = f"INSERT INTO telemetry_raw ({columns}) VALUES ({placeholders})"
    with conn.cursor() as cur:
        cur.executemany(sql, rows)
    conn.commit()
    return len(rows)
