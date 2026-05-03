from datetime import datetime, timedelta, timezone
from random import randint

from lib.client import connect, insert_events
from lib.config import seed_config
from lib.event_factory import build_event

CHUNK_SIZE = 5000


def main() -> None:
    config = seed_config()
    client = connect()
    now = datetime.now(timezone.utc).replace(microsecond=0, tzinfo=None)
    horizon_seconds = config.backfill_hours * 3600

    inserted = 0
    while inserted < config.total_events:
        chunk_size = min(CHUNK_SIZE, config.total_events - inserted)
        rows = [
            build_event(now - timedelta(seconds=randint(0, horizon_seconds)))
            for _ in range(chunk_size)
        ]
        insert_events(client, rows)
        inserted += chunk_size
        print(f"Seeded {inserted}/{config.total_events} historical events")

    print(
        f"Backfill complete: {config.total_events} events across "
        f"{config.backfill_hours}h window"
    )


if __name__ == "__main__":
    main()
