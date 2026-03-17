"""
Interactive DuckDB shell with pre-loaded Parquet data.

Provides an interactive SQL environment for ad-hoc queries
against the retail analytics dataset.
"""

from pathlib import Path

import duckdb

DATA_DIR = Path(__file__).parent.parent / "data" / "processed"


def create_connection() -> duckdb.DuckDBPyConnection:
    """Create DuckDB connection with Parquet files registered as views."""
    conn = duckdb.connect()

    parquet_files = list(DATA_DIR.glob("*.parquet"))

    if not parquet_files:
        print("No Parquet files found. Run 'make transform' first.")
        return conn

    for parquet_file in parquet_files:
        table_name = parquet_file.stem
        conn.execute(f"""
            CREATE VIEW {table_name} AS 
            SELECT * FROM read_parquet('{parquet_file}')
        """)
        print(f"Registered view: {table_name}")

    return conn


def print_help():
    """Display available commands and sample queries."""
    help_text = """
Available Tables:
  - transactions  : Sales transactions
  - products      : Product catalog
  - customers     : Customer data
  - stores        : Store locations

Commands:
  .tables         : List all tables
  .schema TABLE   : Show table schema
  .quit           : Exit shell
  .help           : Show this help

Sample Queries:
  SELECT * FROM transactions LIMIT 10;
  SELECT category, COUNT(*) FROM products GROUP BY category;
  DESCRIBE transactions;
"""
    print(help_text)


def run_shell():
    """Run interactive SQL shell."""
    print("\nDuckDB Interactive Shell")
    print("=" * 50)
    print("Type '.help' for available commands")
    print()

    conn = create_connection()
    print()

    while True:
        try:
            query = input("duckdb> ").strip()

            if not query:
                continue

            if query.lower() in (".quit", ".exit", "quit", "exit"):
                print("Goodbye.")
                break

            if query.lower() == ".help":
                print_help()
                continue

            if query.lower() == ".tables":
                result = conn.execute("""
                    SELECT table_name 
                    FROM information_schema.tables 
                    WHERE table_schema = 'main'
                """).fetchall()
                for row in result:
                    print(f"  {row[0]}")
                continue

            if query.lower().startswith(".schema"):
                parts = query.split()
                if len(parts) < 2:
                    print("Usage: .schema TABLE_NAME")
                    continue
                table_name = parts[1]
                result = conn.execute(f"DESCRIBE {table_name}").fetchall()
                print(f"\nSchema for {table_name}:")
                for row in result:
                    print(f"  {row[0]:20} {row[1]}")
                print()
                continue

            # Execute SQL query
            result = conn.execute(query)
            columns = [desc[0] for desc in result.description]

            # Print header
            header = " | ".join(f"{col:15}" for col in columns)
            print(header)
            print("-" * len(header))

            # Print rows
            rows = result.fetchall()
            for row in rows[:100]:  # Limit output
                print(" | ".join(f"{str(v):15}" for v in row))

            if len(rows) > 100:
                print(f"... ({len(rows) - 100} more rows)")

            print(f"\n({len(rows)} rows)")

        except KeyboardInterrupt:
            print("\nUse '.quit' to exit")
        except Exception as e:
            print(f"Error: {e}")

    conn.close()


if __name__ == "__main__":
    run_shell()
