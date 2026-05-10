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


@dataclass(frozen=True)
class PostgresConfig:
    host: str
    port: int
    database: str
    user: str
    password: str

    def dsn(self) -> str:
        return (
            f"host={self.host} port={self.port} dbname={self.database} "
            f"user={self.user} password={self.password}"
        )


@dataclass(frozen=True)
class SeedConfig:
    total_events: int
    backfill_hours: int


@dataclass(frozen=True)
class StreamConfig:
    batch_size: int
    interval_seconds: float


def postgres_config() -> PostgresConfig:
    return PostgresConfig(
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=_int("POSTGRES_PORT", 5432),
        database=os.getenv("POSTGRES_DB", "telemetry"),
        user=os.getenv("POSTGRES_USER", "telemetry_user"),
        password=os.getenv("POSTGRES_PASSWORD", "telemetry_password"),
    )


def seed_config() -> SeedConfig:
    return SeedConfig(
        total_events=_int("SEED_TOTAL_EVENTS", 80000),
        backfill_hours=_int("SEED_BACKFILL_HOURS", 6),
    )


def stream_config() -> StreamConfig:
    return StreamConfig(
        batch_size=_int("STREAM_BATCH_SIZE", 500),
        interval_seconds=_float("STREAM_INTERVAL_SECONDS", 1.0),
    )
