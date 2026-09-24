import pytest

from pubscout.config import settings
from pubscout.dependencies import get_osm_service
from pubscout.main import app
from pubscout.schemas.activity import ActivitySummary
from pubscout.schemas.venue import VenueResponse
from pubscout.services.osm_service import (
    OverpassApiError,
    OverpassRateLimitError,
    OverpassTimeoutError,
)

BERLIN = {"lat": 52.52, "lng": 13.405}

DART_PUB = VenueResponse(
    name="Dart Pub",
    latitude=52.52,
    longitude=13.405,
    address="Beispielstr. 1, 10115 Berlin",
    osm_id="node/123",
    activities=[ActivitySummary(name="Darts", icon="darts")],
    description="Coole Dart Bar",
    opening_hours="Mo-Fr 18:00-02:00",
    website="https://dartpub.de",
    phone="+49 30 12345",
    outdoor_seating=True,
    wheelchair="yes",
)


class FakeOsmService:
    def __init__(self) -> None:
        self.venues: list[VenueResponse] = []
        self.error: Exception | None = None
        self.calls: list[dict] = []

    async def fetch_venues(self, lat, lng, radius_km, activities=None):
        self.calls.append(
            {"lat": lat, "lng": lng, "radius_km": radius_km, "activities": activities}
        )
        if self.error is not None:
            raise self.error
        return self.venues


@pytest.fixture
def osm_service(client) -> FakeOsmService:
    fake = FakeOsmService()
    app.dependency_overrides[get_osm_service] = lambda: fake
    return fake


async def test_list_venues_returns_venues_in_contract_format(client, osm_service):
    osm_service.venues = [DART_PUB]

    response = await client.get("/venues", params=BERLIN)

    assert response.status_code == 200
    assert response.json() == [
        {
            "name": "Dart Pub",
            "latitude": 52.52,
            "longitude": 13.405,
            "address": "Beispielstr. 1, 10115 Berlin",
            "osm_id": "node/123",
            "activities": [{"name": "Darts", "icon": "darts", "details": ""}],
            "description": "Coole Dart Bar",
            "opening_hours": "Mo-Fr 18:00-02:00",
            "website": "https://dartpub.de",
            "phone": "+49 30 12345",
            "outdoor_seating": True,
            "wheelchair": "yes",
        }
    ]


async def test_list_venues_passes_location_and_radius_to_service(client, osm_service):
    await client.get("/venues", params={**BERLIN, "radius_km": 2.5})

    assert osm_service.calls == [
        {"lat": 52.52, "lng": 13.405, "radius_km": 2.5, "activities": None}
    ]


async def test_list_venues_uses_configured_default_radius(client, osm_service):
    await client.get("/venues", params=BERLIN)

    assert osm_service.calls[0]["radius_km"] == settings.default_search_radius_km


async def test_list_venues_splits_comma_separated_activities(client, osm_service):
    await client.get("/venues", params={**BERLIN, "activities": "darts, billiards"})

    assert osm_service.calls[0]["activities"] == ["darts", "billiards"]


@pytest.mark.parametrize("empty", ["", " ", ",", " , ,"])
async def test_list_venues_treats_empty_activities_as_no_filter(
    client, osm_service, empty
):
    await client.get("/venues", params={**BERLIN, "activities": empty})

    assert osm_service.calls[0]["activities"] is None


async def test_list_venues_rejects_unknown_activity(client, osm_service):
    response = await client.get(
        "/venues", params={**BERLIN, "activities": "darts,Darts"}
    )

    assert response.status_code == 422
    assert "Darts" in response.json()["detail"]
    assert osm_service.calls == []


@pytest.mark.parametrize("missing", ["lat", "lng"])
async def test_list_venues_requires_coordinates(client, osm_service, missing):
    params = {key: value for key, value in BERLIN.items() if key != missing}

    response = await client.get("/venues", params=params)

    assert response.status_code == 422


@pytest.mark.parametrize(
    "invalid",
    [
        {"lat": 90},
        {"lat": -90},
        {"lng": 180.5},
        {"lng": -181},
        {"radius_km": 0},
        {"radius_km": 25.1},
    ],
)
async def test_list_venues_rejects_out_of_range_parameters(
    client, osm_service, invalid
):
    response = await client.get("/venues", params={**BERLIN, **invalid})

    assert response.status_code == 422
    assert osm_service.calls == []


async def test_list_venues_accepts_maximum_radius(client, osm_service):
    response = await client.get("/venues", params={**BERLIN, "radius_km": 25})

    assert response.status_code == 200


@pytest.mark.parametrize(
    ("error", "status_code"),
    [
        (OverpassTimeoutError("slow"), 504),
        (OverpassRateLimitError("busy"), 503),
        (OverpassApiError("broken"), 502),
    ],
)
async def test_list_venues_maps_overpass_errors_to_http_status(
    client, osm_service, error, status_code
):
    osm_service.error = error

    response = await client.get("/venues", params=BERLIN)

    assert response.status_code == status_code
    assert response.json()["detail"]


async def test_list_venues_does_not_leak_upstream_error_text(client, osm_service):
    osm_service.error = OverpassApiError("httpx internals: secret-host:1234")

    response = await client.get("/venues", params=BERLIN)

    assert "secret-host" not in response.json()["detail"]
