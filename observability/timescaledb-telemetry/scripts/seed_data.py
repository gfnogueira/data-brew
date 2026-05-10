from datetime import datetime, timedelta, timezone
from random import randint

from lib.connection import connect, copy_events
from lib.config import seed_config
from lib.sensor_factory import build_event

CHUNK_SIZE = 5000


def main() -> None:
    config = seed_config()
    horizon_seconds = config.backfill_hours * 3600
    now = datetime.now(timezone.utc).replace(microsecond=0)

    print(
        f"Seeding {config.total_events} events across {config.backfill_hours}h via COPY"
    )

    inserted = 0
    with connect() as conn:
        while inserted < config.total_events:
            size = min(CHUNK_SIZE, config.total_events - inserted)
            rows = [
                build_event(now - timedelta(seconds=randint(0, horizon_seconds)))
                for _ in range(size)
            ]
            copy_events(conn, rows)
            inserted += size
            print(f"  seeded {inserted}/{config.total_events}")

    print(f"Backfill complete: {inserted} events written")


if __name__ == "__main__":
    main()
