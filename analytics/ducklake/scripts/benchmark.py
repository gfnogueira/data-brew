import os
import time

from lib.session import open_session

ITERATIONS = int(os.getenv("BENCH_ITERATIONS", "5"))


QUERIES = (
    (
        "latest scan revenue by region",
        """
        SELECT region, sum(amount) AS revenue, count(*) AS events
        FROM events
        WHERE event_time >= now() - INTERVAL '1 day'
        GROUP BY region
        ORDER BY revenue DESC
        """,
    ),
    (
        "time travel at version 1",
        "SELECT count(*) FROM events AT (VERSION => 1)",
    ),
    (
        "snapshot metadata listing",
        "SELECT snapshot_id, schema_version FROM ducklake_snapshots('poc_lake') ORDER BY snapshot_id",
    ),
    (
        "join users x events tier breakdown",
        """
        SELECT u.tier, count(*) AS events, sum(e.amount) AS revenue
        FROM events e JOIN users u USING (user_id)
        WHERE e.event_time >= now() - INTERVAL '1 day'
        GROUP BY u.tier
        ORDER BY revenue DESC
        """,
    ),
)


def main() -> None:
    conn = open_session()
    print(f"Benchmarking {len(QUERIES)} queries x {ITERATIONS} iterations")
    print()
    for label, sql in QUERIES:
        elapsed = []
        for _ in range(ITERATIONS):
            start = time.perf_counter()
            conn.execute(sql).fetchall()
            elapsed.append((time.perf_counter() - start) * 1000.0)
        avg = sum(elapsed) / len(elapsed)
        p_min = min(elapsed)
        p_max = max(elapsed)
        print(f"==> {label}")
        print(f"    avg={avg:8.2f} ms   min={p_min:8.2f} ms   max={p_max:8.2f} ms")
        print()


if __name__ == "__main__":
    main()
