CONTRACT_ACTIVITIES = [
    {"name": "Billard", "icon": "billiards", "osm_tags": ["sport=billiards"]},
    {"name": "Brettspiele", "icon": "board_games", "osm_tags": ["leisure=board_game"]},
    {"name": "Darts", "icon": "darts", "osm_tags": ["leisure=darts", "sport=darts"]},
    {"name": "Kicker", "icon": "foosball", "osm_tags": ["sport=table_soccer"]},
    {"name": "Pool", "icon": "pool", "osm_tags": ["sport=pool"]},
    {"name": "Quiz/Trivia", "icon": "quiz", "osm_tags": ["quiz=yes"]},
    {
        "name": "Shuffleboard",
        "icon": "shuffleboard",
        "osm_tags": ["sport=shuffleboard"],
    },
    {"name": "Tischtennis", "icon": "table_tennis", "osm_tags": ["sport=table_tennis"]},
]


async def test_list_activities_returns_static_list_in_contract_format(client):
    response = await client.get("/activities")

    assert response.status_code == 200
    assert response.json() == CONTRACT_ACTIVITIES


async def test_list_activities_is_sorted_by_name(client):
    response = await client.get("/activities")

    names = [activity["name"] for activity in response.json()]
    assert names == sorted(names)
