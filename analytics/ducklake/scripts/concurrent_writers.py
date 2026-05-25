import os
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
from decimal import Decimal
from random import choice, random, randint
from uuid import uuid4

from lib.session import open_session

WRITERS = int(os.getenv("CONCURRENT_WRITERS", "4"))
BATCH_PER_WRITER = int(os.getenv("CONCURRENT_BATCH", "1000"))
ROUNDS = int(os.getenv("CONCURRENT_ROUNDS", "5"))

PLATFORMS = ("web", "ios", "android")
REGIONS = ("us-east", "us-west", "eu-central", "sa-east", "ap-south")
EVENT_TYPES = ("page_view", "click", "add_to_cart", "checkout", "purchase")


def writer_job(writer_id: int) -> tuple[int, int, float]:
    conn = open_session()
    inserted = 0
    started = time.monotonic()
    for _round in range(ROUNDS):
        rows = []
        now = datetime.now(timezone.utc).replace(microsecond=0)
        for _ in range(BATCH_PER_WRITER):
            event_type = choice(EVENT_TYPES)
            amount = Decimal(f"{random() * 200:.2f}") if event_type == "purchase" else Decimal("0")
            rows.append(
                (
                    str(uuid4()),
                    now,
                    str(uuid4()),
                    event_type,
                    choice(PLATFORMS),
                    choice(REGIONS),
                    amount,
                    200,
                    str(uuid4()),
                )
            )
        conn.executemany(
            """
            INSERT INTO events
              (event_id, event_time, user_id, event_type, client_platform, region, amount, status_code, request_id)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )
        inserted += BATCH_PER_WRITER
    elapsed = time.monotonic() - started
    return writer_id, inserted, elapsed


def main() -> None:
    print(f"Spawning {WRITERS} concurrent writers, {ROUNDS} rounds x {BATCH_PER_WRITER} rows each")
    with ThreadPoolExecutor(max_workers=WRITERS) as pool:
        futures = [pool.submit(writer_job, w) for w in range(WRITERS)]
        for fut in as_completed(futures):
            writer_id, inserted, elapsed = fut.result()
            rate = inserted / elapsed if elapsed > 0 else 0
            print(f"  writer {writer_id}: {inserted} rows in {elapsed:.2f}s ({rate:,.0f} rows/s)")

    audit = open_session()
    snapshots = audit.execute(
        "SELECT count(*) FROM ducklake_snapshots('poc_lake')"
    ).fetchone()
    print(f"Total snapshots after concurrent run: {snapshots[0]}")


if __name__ == "__main__":
    main()
