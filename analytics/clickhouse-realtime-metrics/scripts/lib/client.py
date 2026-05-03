import clickhouse_connect

from .config import ClickHouseConfig, clickhouse_config

INSERT_COLUMNS = (
    "event_id",
    "event_time",
    "user_id",
    "session_id",
    "event_type",
    "platform",
    "region",
    "device_type",
    "revenue_amount",
    "latency_ms",
    "status_code",
)


def connect(config: ClickHouseConfig | None = None, *, async_insert: bool = False):
    config = config or clickhouse_config()
    settings = {}
    if async_insert:
        settings["async_insert"] = 1
        settings["wait_for_async_insert"] = 1

    return clickhouse_connect.get_client(
        host=config.host,
        port=config.http_port,
        username=config.user,
        password=config.password,
        database=config.database,
        settings=settings,
    )


def insert_events(client, rows) -> None:
    client.insert(
        "user_events_raw",
        rows,
        column_names=list(INSERT_COLUMNS),
    )
