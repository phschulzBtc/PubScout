import pytest

from pubscout.services.osm_service import (
    OverpassApiError,
    OverpassRateLimitError,
    OverpassTimeoutError,
)


@pytest.mark.asyncio
async def test_list_venues_requires_lat_lng(client):
    response = await client.get("/venues")
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_list_venues_returns_results(client, mock_osm_service, sample_venues):
    mock_osm_service.fetch_venues.return_value = sample_venues

    response = await client.get("/venues?lat=52.52&lng=13.405")
    assert response.status_code == 200

    data = response.json()
    assert len(data) == 2
    assert data[0]["name"] == "Test Bar"
    assert data[0]["osm_id"] == "node/123"
    assert data[0]["activities"][0]["name"] == "Darts"

    mock_osm_service.fetch_venues.assert_called_once_with(52.52, 13.405, 5.0, None)


@pytest.mark.asyncio
async def test_list_venues_with_radius(client, mock_osm_service):
    mock_osm_service.fetch_venues.return_value = []

    response = await client.get("/venues?lat=52.52&lng=13.405&radius_km=10")
    assert response.status_code == 200

    mock_osm_service.fetch_venues.assert_called_once_with(52.52, 13.405, 10.0, None)


@pytest.mark.asyncio
async def test_list_venues_with_activity_filter(client, mock_osm_service):
    mock_osm_service.fetch_venues.return_value = []

    response = await client.get("/venues?lat=52.52&lng=13.405&activities=darts,pool")
    assert response.status_code == 200

    mock_osm_service.fetch_venues.assert_called_once_with(
        52.52, 13.405, 5.0, ["darts", "pool"]
    )


@pytest.mark.asyncio
async def test_list_venues_validates_lat_range(client):
    response = await client.get("/venues?lat=91&lng=13.405")
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_list_venues_validates_lng_range(client):
    response = await client.get("/venues?lat=52.52&lng=181")
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_list_venues_validates_radius_range(client):
    response = await client.get("/venues?lat=52.52&lng=13.405&radius_km=0")
    assert response.status_code == 422

    response = await client.get("/venues?lat=52.52&lng=13.405&radius_km=51")
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_list_venues_returns_504_on_overpass_timeout(client, mock_osm_service):
    mock_osm_service.fetch_venues.side_effect = OverpassTimeoutError("timed out")

    response = await client.get("/venues?lat=52.52&lng=13.405")
    assert response.status_code == 504
    assert "retry" in response.json()["detail"]


@pytest.mark.asyncio
async def test_list_venues_returns_429_on_rate_limit(client, mock_osm_service):
    mock_osm_service.fetch_venues.side_effect = OverpassRateLimitError("rate limit")

    response = await client.get("/venues?lat=52.52&lng=13.405")
    assert response.status_code == 429


@pytest.mark.asyncio
async def test_list_venues_returns_502_on_api_error(client, mock_osm_service):
    mock_osm_service.fetch_venues.side_effect = OverpassApiError("server error")

    response = await client.get("/venues?lat=52.52&lng=13.405")
    assert response.status_code == 502
