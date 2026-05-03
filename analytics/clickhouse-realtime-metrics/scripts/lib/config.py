import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv

ENV_PATH = Path(__file__).resolve().parents[2] / ".env"
if ENV_PATH.exists():
    load_dotenv(ENV_PATH)


def _int(name: str, default: int) -> int:
    return int(os.getenv(name, default))


def _float(name: str, default: float) -> float:
    return float(os.getenv(name, default))


def _bool(name: str, default: bool) -> bool:
    return os.getenv(name, str(int(default))).lower() in {"1", "true", "yes"}


@dataclass(frozen=True)
class ClickHouseConfig:
    host: str
    http_port: int
    database: str
    user: str
    password: str


@dataclass(frozen=True)
class SeedConfig:
    total_events: int
    backfill_hours: int


@dataclass(frozen=True)
class StreamConfig:
    batch_size: int
    interval_seconds: float
    async_insert: bool


def clickhouse_config() -> ClickHouseConfig:
    return ClickHouseConfig(
        host=os.getenv("CLICKHOUSE_HOST", "localhost"),
        http_port=_int("CLICKHOUSE_HTTP_PORT", 8123),
        database=os.getenv("CLICKHOUSE_DATABASE", "realtime"),
        user=os.getenv("CLICKHOUSE_USER", "metrics_user"),
        password=os.getenv("CLICKHOUSE_PASSWORD", "metrics_password"),
    )


def seed_config() -> SeedConfig:
    return SeedConfig(
        total_events=_int("SEED_TOTAL_EVENTS", 60000),
        backfill_hours=_int("SEED_BACKFILL_HOURS", 2),
    )


def stream_config() -> StreamConfig:
    return StreamConfig(
        batch_size=_int("STREAM_BATCH_SIZE", 500),
        interval_seconds=_float("STREAM_INTERVAL_SECONDS", 1.0),
        async_insert=_bool("STREAM_ASYNC_INSERT", True),
    )
