import asyncio
from collections.abc import Awaitable, Callable


class SingleFlight[T]:
    """Concurrent calls with the same key share one execution (result or error)."""

    def __init__(self) -> None:
        self._tasks: dict[str, asyncio.Task[T]] = {}

    @property
    def in_flight(self) -> int:
        return len(self._tasks)

    async def run(self, key: str, factory: Callable[[], Awaitable[T]]) -> T:
        task = self._tasks.get(key)
        if task is None:
            task = asyncio.ensure_future(factory())
            self._tasks[key] = task
            task.add_done_callback(lambda done: self._forget(key, done))
        # shield: one cancelled caller must not cancel the execution for the others
        return await asyncio.shield(task)

    def _forget(self, key: str, task: asyncio.Task[T]) -> None:
        if self._tasks.get(key) is task:
            del self._tasks[key]
        if not task.cancelled():
            task.exception()  # mark as retrieved even if every caller gave up
