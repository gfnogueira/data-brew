from datetime import datetime, timedelta, timezone
from decimal import Decimal
from random import choice, randint, random
from uuid import uuid4

COUNTRIES = ("BR", "US", "DE", "FR", "JP", "AU", "CA", "ES", "IN", "ZA")
TIERS = ("free", "starter", "pro", "enterprise")
PLATFORMS = ("web", "ios", "android")
REGIONS = ("us-east", "us-west", "eu-central", "sa-east", "ap-south")
EVENT_TYPES = ("page_view", "click", "add_to_cart", "checkout", "purchase")
REVENUE_EVENTS = {"purchase"}


def build_user() -> tuple:
    signup = datetime.now(timezone.utc).replace(microsecond=0) - timedelta(
        seconds=randint(0, 60 * 60 * 24 * 30)
    )
    return (
        str(uuid4()),
        f"user{randint(1, 1_000_000)}@example.com",
        signup,
        choice(COUNTRIES),
        choice(TIERS),
    )


def build_event(user_id: str, when: datetime | None = None) -> tuple:
    when = when or datetime.now(timezone.utc).replace(microsecond=0)
    event_type = choice(EVENT_TYPES)
    amount = Decimal(f"{random() * 320:.2f}") if event_type in REVENUE_EVENTS else Decimal("0")
    status = 200 if random() > 0.02 else choice((500, 502, 503))
    return (
        str(uuid4()),
        when,
        user_id,
        event_type,
        choice(PLATFORMS),
        choice(REGIONS),
        amount,
        status,
    )
