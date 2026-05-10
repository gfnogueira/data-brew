import time
from datetime import datetime, timezone

from lib.connection import connect, insert_batch
from lib.config import stream_config
from lib.sensor_factory import build_batch


def main() -> None:
    config = stream_config()
    print(
        f"Streaming events: batch={config.batch_size} interval={config.interval_seconds}s. "
        f"Stop with Ctrl+C."
    )
    cycles = 0
    with connect() as conn:
        try:
            while True:
                now = datetime.now(timezone.utc).replace(microsecond=0)
                rows = build_batch(config.batch_size, now)
                insert_batch(conn, rows)
                cycles += 1
                if cycles % 10 == 0:
                    print(
                        f"[{now.isoformat()}] streamed {cycles * config.batch_size} events"
                    )
                time.sleep(config.interval_seconds)
        except KeyboardInterrupt:
            print(f"Stopped after {cycles} cycles, {cycles * config.batch_size} events")


if __name__ == "__main__":
    main()
