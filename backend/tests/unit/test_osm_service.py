from collections.abc import AsyncIterator, Callable
from urllib.parse import parse_qs

import httpx
import pytest

from pubscout.services.osm_service import (
    OVERPASS_MIN_REQUEST_INTERVAL_SECONDS,
    OsmService,
    OverpassApiError,
    OverpassClient,
    OverpassRateLimitError,
    OverpassTimeoutError,
)
from pubscout.services.rate_limiter import RateLimiter

OVERPASS_TEST_URL = "https://overpass.test/api/interpreter"

DART_PUB_RESPONSE = {
    "elements": [
        {
            "type": "node",
            "id": 1,
            "lat": 52.52,
            "lon": 13.405,
            "tags": {"amenity": "pub", "name": "Dart Pub", "sport": "darts"},
        }
    ]
}

Handler = Callable[[httpx.Request], httpx.Response]
ClientFactory = Callable[..., OverpassClient]


class RecordingRateLimiter(RateLimiter):
    def __init__(self) -> None:
        super().__init__(min_interval_seconds=0)
        self.calls = 0

    async def wait_for_slot(self) -> None:
        self.calls += 1


@pytest.fixture
async def make_client() -> AsyncIterator[ClientFactory]:
    http_clients: list[httpx.AsyncClient] = []

    def factory(
        handler: Handler, rate_limiter: RateLimiter | None = None
    ) -> OverpassClient:
        http_client = httpx.AsyncClient(transport=httpx.MockTransport(handler))
        http_clients.append(http_client)
        return OverpassClient(
            http_client=http_client,
            api_url=OVERPASS_TEST_URL,
            rate_limiter=rate_limiter or RecordingRateLimiter(),
        )

    yield factory
    for http_client in http_clients:
        await http_client.aclose()


def _sent_query(request: httpx.Request) -> str:
    return parse_qs(request.content.decode())["data"][0]


def _recording_handler(queries: list[str]) -> Handler:
    def handler(request: httpx.Request) -> httpx.Response:
        queries.append(_sent_query(request))
        return httpx.Response(200, json={"elements": []})

    return handler


async def test_client_posts_query_as_form_data_and_returns_json(make_client):
    requests: list[httpx.Request] = []

    def handler(request: httpx.Request) -> httpx.Response:
        requests.append(request)
        return httpx.Response(200, json=DART_PUB_RESPONSE)

    result = await make_client(handler).query("[out:json];")

    assert result == DART_PUB_RESPONSE
    assert str(requests[0].url) == OVERPASS_TEST_URL
    assert _sent_query(requests[0]) == "[out:json];"


async def test_client_identifies_itself_with_pubscout_user_agent(make_client):
    requests: list[httpx.Request] = []

    def handler(request: httpx.Request) -> httpx.Response:
        requests.append(request)
        return httpx.Response(200, json={})

    await make_client(handler).query("q")

    assert requests[0].headers["User-Agent"].startswith("PubScout/")


async def test_client_waits_for_rate_limiter_before_request(make_client):
    rate_limiter = RecordingRateLimiter()
    client = make_client(lambda _: httpx.Response(200, json={}), rate_limiter)

    await client.query("q")

    assert rate_limiter.calls == 1


async def test_client_defaults_to_one_request_per_second():
    async with httpx.AsyncClient() as http_client:
        client = OverpassClient(http_client=http_client, api_url=OVERPASS_TEST_URL)

    assert OVERPASS_MIN_REQUEST_INTERVAL_SECONDS == 1.0
    assert client.rate_limiter.min_interval_seconds == 1.0


async def test_client_raises_rate_limit_error_on_http_429(make_client):
    client = make_client(lambda _: httpx.Response(429))

    with pytest.raises(OverpassRateLimitError):
        await client.query("q")


async def test_client_raises_api_error_on_server_error(make_client):
    client = make_client(lambda _: httpx.Response(504))

    with pytest.raises(OverpassApiError):
        await client.query("q")


async def test_client_raises_api_error_on_non_json_body(make_client):
    client = make_client(lambda _: httpx.Response(200, text="<html>busy</html>"))

    with pytest.raises(OverpassApiError):
        await client.query("q")


async def test_client_raises_timeout_error_on_query_timeout_remark(make_client):
    body = {"elements": [], "remark": "runtime error: Query timed out in 25s"}
    client = make_client(lambda _: httpx.Response(200, json=body))

    with pytest.raises(OverpassTimeoutError):
        await client.query("q")


async def test_client_raises_api_error_on_runtime_error_remark(make_client):
    body = {"elements": [], "remark": "runtime error: Query run out of memory"}
    client = make_client(lambda _: httpx.Response(200, json=body))

    with pytest.raises(OverpassApiError):
        await client.query("q")


async def test_client_raises_timeout_error_on_timeout(make_client):
    def handler(request: httpx.Request) -> httpx.Response:
        raise httpx.ReadTimeout("slow", request=request)

    with pytest.raises(OverpassTimeoutError):
        await make_client(handler).query("q")


async def test_client_raises_api_error_on_connection_failure(make_client):
    def handler(request: httpx.Request) -> httpx.Response:
        raise httpx.ConnectError("down", request=request)

    with pytest.raises(OverpassApiError):
        await make_client(handler).query("q")


def test_timeout_and_rate_limit_errors_are_api_errors():
    assert issubclass(OverpassTimeoutError, OverpassApiError)
    assert issubclass(OverpassRateLimitError, OverpassApiError)


async def test_fetch_venues_returns_parsed_venues(make_client):
    client = make_client(lambda _: httpx.Response(200, json=DART_PUB_RESPONSE))

    venues = await OsmService(client).fetch_venues(52.52, 13.405, radius_km=1.0)

    assert [venue.osm_id for venue in venues] == ["node/1"]
    assert venues[0].activities[0].icon == "darts"


async def test_fetch_venues_without_filter_queries_all_activities(make_client):
    queries: list[str] = []
    service = OsmService(make_client(_recording_handler(queries)))

    await service.fetch_venues(52.52, 13.405, radius_km=1.0)

    assert "darts" in queries[0]
    assert "billiards" in queries[0]


async def test_fetch_venues_with_filter_queries_only_requested_activities(
    make_client,
):
    queries: list[str] = []
    service = OsmService(make_client(_recording_handler(queries)))

    await service.fetch_venues(52.52, 13.405, radius_km=1.0, activities=["pool"])

    assert "pool" in queries[0]
    assert "darts" not in queries[0]


@pytest.mark.parametrize("activities", [[], ["bowling"]])
async def test_fetch_venues_without_known_activities_skips_request(
    make_client, activities
):
    queries: list[str] = []
    service = OsmService(make_client(_recording_handler(queries)))

    venues = await service.fetch_venues(
        52.52, 13.405, radius_km=1.0, activities=activities
    )

    assert venues == []
    assert queries == []
