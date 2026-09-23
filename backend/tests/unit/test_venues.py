import pytest

from pubscout.models.activity import Activity
from pubscout.models.venue import Venue


@pytest.mark.asyncio
async def test_list_venues_empty(client):
    response = await client.get("/venues")
    assert response.status_code == 200
    assert response.json() == []


@pytest.mark.asyncio
async def test_list_venues_with_activities(client, session):
    activity = Activity(name="Darts", icon="darts")
    session.add(activity)
    await session.flush()

    venue = Venue(
        name="Test Bar",
        latitude=52.52,
        longitude=13.405,
        address="Teststr. 1, Berlin",
        osm_id="node/123",
        activities=[activity],
    )
    session.add(venue)
    await session.commit()

    response = await client.get("/venues")
    assert response.status_code == 200

    data = response.json()
    assert len(data) == 1
    assert data[0]["name"] == "Test Bar"
    assert data[0]["latitude"] == 52.52
    assert data[0]["osm_id"] == "node/123"
    assert len(data[0]["activities"]) == 1
    assert data[0]["activities"][0]["name"] == "Darts"
