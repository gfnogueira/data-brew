from datetime import datetime, timedelta
from random import choice, randint, random
from uuid import uuid4

REGIONS = ("us-east", "us-west", "eu-central", "eu-west", "sa-east", "ap-south")
PLATFORMS = ("web", "ios", "android")
DEVICE_TYPES = ("desktop", "mobile", "tablet")
EVENT_TYPES = ("page_view", "click", "search", "add_to_cart", "checkout", "purchase")

REVENUE_EVENTS = {"purchase"}
ERROR_RATE = 0.015
SLOW_TAIL_RATE = 0.05


def _latency() -> int:
    base = randint(20, 350)
    if random() < SLOW_TAIL_RATE:
        return base + randint(400, 2400)
    return base


def _status_code() -> int:
    if random() < ERROR_RATE:
        return choice((500, 502, 503, 504))
    return choice((200, 200, 200, 200, 204, 301))


def build_event(timestamp: datetime) -> tuple:
    event_type = choice(EVENT_TYPES)
    revenue = round(random() * 320, 2) if event_type in REVENUE_EVENTS else 0.0
    return (
        str(uuid4()),
        timestamp,
        f"user_{randint(1000, 99999)}",
        f"session_{randint(100000, 9999999)}",
        event_type,
        choice(PLATFORMS),
        choice(REGIONS),
        choice(DEVICE_TYPES),
        revenue,
        _latency(),
        _status_code(),
    )


def build_batch(size: int, reference: datetime, jitter_seconds: int = 0) -> list:
    if jitter_seconds <= 0:
        return [build_event(reference) for _ in range(size)]
    return [
        build_event(reference - timedelta(seconds=randint(0, jitter_seconds)))
        for _ in range(size)
    ]
