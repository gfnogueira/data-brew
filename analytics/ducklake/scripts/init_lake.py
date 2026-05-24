from pathlib import Path

from lib.session import open_session

SETUP_DIR = Path(__file__).resolve().parent.parent / "sql" / "setup"


def main() -> None:
    conn = open_session()
    create_tables_sql = (SETUP_DIR / "03_create_tables.sql").read_text(encoding="utf-8")
    conn.execute(create_tables_sql)
    tables = conn.execute("SHOW TABLES").fetchall()
    print("Tables present in lake:")
    for (table_name,) in tables:
        print(f"  - {table_name}")


if __name__ == "__main__":
    main()
