import asyncio

from pubscout.services.rate_limiter import RateLimiter


class FakeClock:
    def __init__(self) -> None:
        self.now = 100.0
        self.sleeps: list[float] = []

    def monotonic(self) -> float:
        return self.now

    async def sleep(self, seconds: float) -> None:
        self.sleeps.append(seconds)
        self.now += seconds


def _limiter(clock: FakeClock) -> RateLimiter:
    return RateLimiter(
        min_interval_seconds=1.0, clock=clock.monotonic, sleep=clock.sleep
    )


async def test_first_request_does_not_wait():
    clock = FakeClock()

    await _limiter(clock).wait_for_slot()

    assert clock.sleeps == []


async def test_request_within_interval_waits_for_remaining_time():
    clock = FakeClock()
    limiter = _limiter(clock)

    await limiter.wait_for_slot()
    clock.now += 0.25
    await limiter.wait_for_slot()

    assert clock.sleeps == [0.75]


async def test_request_after_interval_does_not_wait():
    clock = FakeClock()
    limiter = _limiter(clock)

    await limiter.wait_for_slot()
    clock.now += 1.5
    await limiter.wait_for_slot()

    assert clock.sleeps == []


async def test_concurrent_requests_are_spaced_by_interval():
    clock = FakeClock()
    limiter = _limiter(clock)

    await asyncio.gather(*(limiter.wait_for_slot() for _ in range(3)))

    assert clock.sleeps == [1.0, 1.0]
