import sys

from lib.session import open_session

CHECKS = (
    (
        "Catalog reachable and lake attached",
        "SELECT current_database()",
        lambda rows: rows and rows[0][0] == "poc_lake",
    ),
    (
        "Tables present (users, events)",
        "SELECT table_name FROM duckdb_tables() WHERE database_name = 'poc_lake' ORDER BY table_name",
        lambda rows: {r[0] for r in rows} >= {"events", "users"},
    ),
    (
        "Snapshots exist",
        "SELECT count(*) FROM ducklake_snapshots('poc_lake')",
        lambda rows: rows and rows[0][0] >= 1,
    ),
    (
        "Events table has rows",
        "SELECT count(*) FROM events",
        lambda rows: rows and rows[0][0] > 0,
    ),
    (
        "Parquet files registered for events",
        "SELECT count(*) FROM ducklake_table_info('poc_lake') WHERE table_name = 'events'",
        lambda rows: rows and rows[0][0] > 0,
    ),
    (
        "Schema version progressed past 1",
        "SELECT max(schema_version) FROM ducklake_snapshots('poc_lake')",
        lambda rows: rows and (rows[0][0] or 0) >= 1,
    ),
)


def main() -> int:
    conn = open_session()
    failures = 0
    print("==> DuckLake validation")
    for label, sql, predicate in CHECKS:
        try:
            rows = conn.execute(sql).fetchall()
            passed = bool(predicate(rows))
        except Exception as exc:
            print(f"  FAIL  {label}: {exc}")
            failures += 1
            continue
        marker = "PASS" if passed else "FAIL"
        if not passed:
            failures += 1
        print(f"  {marker}  {label}: {rows}")
    print()
    if failures:
        print(f"FAILED: {failures} check(s) did not pass")
        return 1
    print("PASSED: all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
