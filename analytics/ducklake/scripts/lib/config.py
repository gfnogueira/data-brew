import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv

ENV_PATH = Path(__file__).resolve().parents[2] / ".env"
if ENV_PATH.exists():
    load_dotenv(ENV_PATH)


def _int(name: str, default: int) -> int:
    return int(os.getenv(name, default))


@dataclass(frozen=True)
class CatalogConfig:
    host: str
    port: int
    database: str
    user: str
    password: str

    def attach_string(self) -> str:
        return (
            f"dbname={self.database} host={self.host} port={self.port} "
            f"user={self.user} password={self.password}"
        )


@dataclass(frozen=True)
class StorageConfig:
    endpoint: str
    access_key: str
    secret_key: str
    bucket: str
    region: str


@dataclass(frozen=True)
class LakeConfig:
    name: str
    data_path: str


def catalog_config() -> CatalogConfig:
    return CatalogConfig(
        host=os.getenv("CATALOG_HOST", "localhost"),
        port=_int("CATALOG_PORT", 5433),
        database=os.getenv("CATALOG_DB", "ducklake_catalog"),
        user=os.getenv("CATALOG_USER", "ducklake"),
        password=os.getenv("CATALOG_PASSWORD", "ducklake_password"),
    )


def storage_config() -> StorageConfig:
    return StorageConfig(
        endpoint=os.getenv("STORAGE_ENDPOINT", "http://localhost:9000"),
        access_key=os.getenv("STORAGE_ACCESS_KEY", "minioadmin"),
        secret_key=os.getenv("STORAGE_SECRET_KEY", "minioadmin"),
        bucket=os.getenv("STORAGE_BUCKET", "lakehouse"),
        region=os.getenv("STORAGE_REGION", "us-east-1"),
    )


def lake_config() -> LakeConfig:
    return LakeConfig(
        name=os.getenv("LAKE_NAME", "poc_lake"),
        data_path=os.getenv("LAKE_DATA_PATH", "s3://lakehouse/data/"),
    )
