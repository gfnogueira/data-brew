import duckdb

from .config import catalog_config, lake_config, storage_config


def open_session() -> duckdb.DuckDBPyConnection:
    """Open a DuckDB session with DuckLake attached to the configured catalog and storage."""
    storage = storage_config()
    catalog = catalog_config()
    lake = lake_config()

    conn = duckdb.connect(database=":memory:")
    for stmt in (
        "INSTALL ducklake",
        "INSTALL postgres",
        "INSTALL httpfs",
        "LOAD ducklake",
        "LOAD postgres",
        "LOAD httpfs",
    ):
        conn.execute(stmt)

    conn.execute(
        """
        CREATE OR REPLACE SECRET storage_secret (
          TYPE      S3,
          KEY_ID    ?,
          SECRET    ?,
          ENDPOINT  ?,
          REGION    ?,
          URL_STYLE 'path',
          USE_SSL   false
        )
        """,
        [
            storage.access_key,
            storage.secret_key,
            storage.endpoint.replace("http://", "").replace("https://", ""),
            storage.region,
        ],
    )

    attach_target = f"ducklake:postgres:{catalog.attach_string()}"
    conn.execute(
        f"ATTACH '{attach_target}' AS {lake.name} (DATA_PATH '{lake.data_path}')"
    )
    conn.execute(f"USE {lake.name}")
    return conn
