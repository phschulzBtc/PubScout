import asyncio
import time
from collections.abc import Awaitable, Callable


class RateLimiter:
    """Ensures a minimum interval between consecutive requests."""

    def __init__(
        self,
        min_interval_seconds: float,
        clock: Callable[[], float] = time.monotonic,
        sleep: Callable[[float], Awaitable[None]] = asyncio.sleep,
    ) -> None:
        self._min_interval_seconds = min_interval_seconds
        self._clock = clock
        self._sleep = sleep
        self._last_request_at: float | None = None
        self._lock = asyncio.Lock()

    @property
    def min_interval_seconds(self) -> float:
        return self._min_interval_seconds

    async def wait_for_slot(self) -> None:
        async with self._lock:
            remaining = self._remaining_wait_seconds()
            if remaining > 0:
                await self._sleep(remaining)
            self._last_request_at = self._clock()

    def _remaining_wait_seconds(self) -> float:
        if self._last_request_at is None:
            return 0.0
        elapsed = self._clock() - self._last_request_at
        return self._min_interval_seconds - elapsed
