from datetime import datetime, timedelta
from random import choice, gauss, randint, random

REGIONS = ("us-east", "us-west", "eu-central", "eu-west", "sa-east", "ap-south")
PLANTS = ("plant-a", "plant-b", "plant-c", "plant-d")
DEVICE_COUNT = 240

SENSOR_PROFILES = {
    "temperature": {"mean": 65.0, "stddev": 4.5, "unit": "celsius"},
    "pressure":    {"mean": 12.0, "stddev": 0.8, "unit": "bar"},
    "vibration":   {"mean": 1.4,  "stddev": 0.3, "unit": "mm/s"},
    "humidity":    {"mean": 48.0, "stddev": 6.0, "unit": "percent"},
    "voltage":     {"mean": 220.0, "stddev": 3.0, "unit": "volt"},
    "flow_rate":   {"mean": 32.0, "stddev": 2.5, "unit": "lpm"},
}

QUALITY_BAD_RATE = 0.012
QUALITY_UNCERTAIN_RATE = 0.04
STATUS_FAULT_RATE = 0.008


def _quality() -> int:
    r = random()
    if r < QUALITY_BAD_RATE:
        return 0
    if r < QUALITY_BAD_RATE + QUALITY_UNCERTAIN_RATE:
        return 1
    return 2


def _status_code() -> int:
    if random() < STATUS_FAULT_RATE:
        return choice((101, 102, 103, 200, 201))
    return 0


def _device_id(idx: int) -> str:
    return f"dev-{idx:04d}"


def build_event(timestamp: datetime) -> tuple:
    sensor_type, profile = choice(list(SENSOR_PROFILES.items()))
    measurement = round(gauss(profile["mean"], profile["stddev"]), 4)
    return (
        timestamp,
        _device_id(randint(1, DEVICE_COUNT)),
        sensor_type,
        choice(REGIONS),
        choice(PLANTS),
        measurement,
        _quality(),
        _status_code(),
    )


def build_batch(size: int, reference: datetime, jitter_seconds: int = 0) -> list:
    if jitter_seconds <= 0:
        return [build_event(reference) for _ in range(size)]
    return [
        build_event(reference - timedelta(seconds=randint(0, jitter_seconds)))
        for _ in range(size)
    ]
