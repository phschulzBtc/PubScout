import pytest


@pytest.mark.asyncio
async def test_list_activities(client):
    response = await client.get("/activities")
    assert response.status_code == 200

    data = response.json()
    assert len(data) == 8

    names = {a["name"] for a in data}
    assert "Darts" in names
    assert "Billard" in names
    assert "Kicker" in names

    for activity in data:
        assert "name" in activity
        assert "icon" in activity
        assert "osm_tags" in activity
        assert isinstance(activity["osm_tags"], list)
        assert "id" not in activity


@pytest.mark.asyncio
async def test_activities_sorted_by_name(client):
    response = await client.get("/activities")
    data = response.json()

    names = [a["name"] for a in data]
    assert names == sorted(names)


@pytest.mark.asyncio
async def test_activities_contain_osm_tags(client):
    response = await client.get("/activities")
    data = response.json()

    darts = next(a for a in data if a["name"] == "Darts")
    assert "sport=darts" in darts["osm_tags"]
    assert darts["icon"] == "darts"
