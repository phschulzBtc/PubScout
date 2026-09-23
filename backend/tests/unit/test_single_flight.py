import asyncio

import pytest

from pubscout.services.single_flight import SingleFlight


class CountingFactory:
    def __init__(self, result: str = "venues", error: Exception | None = None):
        self.calls = 0
        self._result = result
        self._error = error

    async def __call__(self) -> str:
        self.calls += 1
        await asyncio.sleep(0.01)
        if self._error is not None:
            raise self._error
        return self._result


async def test_concurrent_calls_with_same_key_share_one_execution():
    flight = SingleFlight()
    factory = CountingFactory()

    results = await asyncio.gather(*(flight.run("berlin", factory) for _ in range(3)))

    assert results == ["venues", "venues", "venues"]
    assert factory.calls == 1


async def test_concurrent_calls_share_the_same_error():
    flight = SingleFlight()
    factory = CountingFactory(error=RuntimeError("overpass down"))

    results = await asyncio.gather(
        *(flight.run("berlin", factory) for _ in range(3)), return_exceptions=True
    )

    assert factory.calls == 1
    assert all(isinstance(result, RuntimeError) for result in results)


async def test_different_keys_run_separately():
    flight = SingleFlight()
    factory = CountingFactory()

    await asyncio.gather(flight.run("berlin", factory), flight.run("hamburg", factory))

    assert factory.calls == 2


async def test_finished_key_runs_again_and_is_forgotten():
    flight = SingleFlight()
    factory = CountingFactory()

    await flight.run("berlin", factory)
    await flight.run("berlin", factory)

    assert factory.calls == 2
    assert flight.in_flight == 0


async def test_cancelled_caller_does_not_cancel_shared_execution():
    flight = SingleFlight()
    factory = CountingFactory()
    impatient = asyncio.create_task(flight.run("berlin", factory))
    patient = asyncio.create_task(flight.run("berlin", factory))
    await asyncio.sleep(0)

    impatient.cancel()

    assert await patient == "venues"
    with pytest.raises(asyncio.CancelledError):
        await impatient
