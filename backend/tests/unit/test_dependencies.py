import httpx
from fastapi import FastAPI
from starlette.requests import Request

from pubscout.config import settings
from pubscout.dependencies import (
    create_osm_service,
    get_osm_service,
    osm_service_lifespan,
)
from pubscout.services.osm_service import OsmService


async def test_create_osm_service_uses_configured_overpass_url():
    requests: list[httpx.Request] = []

    def handler(request: httpx.Request) -> httpx.Response:
        requests.append(request)
        return httpx.Response(200, json={"elements": []})

    async with httpx.AsyncClient(transport=httpx.MockTransport(handler)) as client:
        service = create_osm_service(client)
        await service.fetch_venues(52.52, 13.405, radius_km=1.0)

    assert isinstance(service, OsmService)
    assert str(requests[0].url) == settings.overpass_api_url


def test_get_osm_service_returns_shared_service_from_app_state():
    app = FastAPI()
    shared = object()
    app.state.osm_service = shared
    request = Request({"type": "http", "app": app})

    assert get_osm_service(request) is shared


async def test_osm_service_lifespan_provides_service_and_closes_client():
    app = FastAPI()

    async with osm_service_lifespan(app) as http_client:
        assert isinstance(app.state.osm_service, OsmService)
        assert not http_client.is_closed

    assert http_client.is_closed
