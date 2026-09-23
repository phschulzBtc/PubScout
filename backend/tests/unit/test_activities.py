import pytest

from pubscout.db.seed import seed_activities


@pytest.mark.asyncio
async def test_list_activities_empty(client):
    response = await client.get("/activities")
    assert response.status_code == 200
    assert response.json() == []


@pytest.mark.asyncio
async def test_list_activities_seeded(client, session):
    await seed_activities(session)

    response = await client.get("/activities")
    assert response.status_code == 200

    data = response.json()
    assert len(data) >= 5

    names = {a["name"] for a in data}
    assert "Darts" in names
    assert "Billard" in names
    assert "Kicker" in names

    for activity in data:
        assert "id" in activity
        assert "name" in activity
        assert "icon" in activity


@pytest.mark.asyncio
async def test_seed_is_idempotent(client, session):
    await seed_activities(session)
    await seed_activities(session)

    response = await client.get("/activities")
    assert response.status_code == 200
    assert len(response.json()) == 8
