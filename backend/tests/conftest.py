from unittest.mock import AsyncMock

import pytest
from httpx import ASGITransport, AsyncClient

from pubscout.main import app
from pubscout.schemas.activity import ActivitySummary
from pubscout.schemas.venue import VenueResponse


@pytest.fixture
def mock_osm_service():
    return AsyncMock()


@pytest.fixture
async def client(mock_osm_service):
    app.state.osm_service = mock_osm_service
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        yield client


@pytest.fixture
def sample_venues():
    return [
        VenueResponse(
            name="Test Bar",
            latitude=52.52,
            longitude=13.405,
            address="Teststr. 1, 10115 Berlin",
            osm_id="node/123",
            activities=[ActivitySummary(name="Darts", icon="darts")],
        ),
        VenueResponse(
            name="Pool Hall",
            latitude=52.51,
            longitude=13.41,
            address="Poolstr. 2, 10115 Berlin",
            osm_id="node/456",
            activities=[ActivitySummary(name="Pool", icon="pool")],
        ),
    ]
