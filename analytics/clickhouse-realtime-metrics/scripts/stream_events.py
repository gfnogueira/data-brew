import time
from datetime import datetime, timezone

from lib.client import connect, insert_events
from lib.config import stream_config
from lib.event_factory import build_batch


def main() -> None:
    config = stream_config()
    client = connect(async_insert=config.async_insert)

    print(
        f"Streaming events: batch={config.batch_size} interval={config.interval_seconds}s "
        f"async_insert={config.async_insert}. Stop with Ctrl+C."
    )
    cycles = 0
    try:
        while True:
            now = datetime.now(timezone.utc).replace(microsecond=0, tzinfo=None)
            rows = build_batch(config.batch_size, now)
            insert_events(client, rows)
            cycles += 1
            if cycles % 10 == 0:
                print(f"[{now.isoformat()}Z] streamed {cycles * config.batch_size} events")
            time.sleep(config.interval_seconds)
    except KeyboardInterrupt:
        print(f"Stopped after {cycles} cycles, {cycles * config.batch_size} events")


if __name__ == "__main__":
    main()
