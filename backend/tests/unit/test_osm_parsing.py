from pubscout.services.osm_service import parse_overpass_response


def _payload(*elements: dict) -> dict:
    return {"elements": list(elements)}


def test_parse_node_into_venue_with_activities():
    node = {
        "type": "node",
        "id": 123,
        "lat": 52.52,
        "lon": 13.405,
        "tags": {"amenity": "pub", "name": "Dart Pub", "sport": "darts"},
    }

    [venue] = parse_overpass_response(_payload(node))

    assert venue.name == "Dart Pub"
    assert venue.latitude == 52.52
    assert venue.longitude == 13.405
    assert venue.osm_id == "node/123"
    assert [(a.name, a.icon) for a in venue.activities] == [("Darts", "darts")]


def test_parse_way_uses_center_coordinates():
    way = {
        "type": "way",
        "id": 456,
        "center": {"lat": 52.5, "lon": 13.4},
        "tags": {"amenity": "bar", "name": "Pool Bar", "sport": "pool"},
    }

    [venue] = parse_overpass_response(_payload(way))

    assert (venue.latitude, venue.longitude) == (52.5, 13.4)
    assert venue.osm_id == "way/456"


def test_parse_builds_address_from_address_tags():
    node = {
        "type": "node",
        "id": 1,
        "lat": 1.0,
        "lon": 2.0,
        "tags": {
            "name": "Bar Example",
            "addr:street": "Beispielstr.",
            "addr:housenumber": "1",
            "addr:postcode": "10115",
            "addr:city": "Berlin",
        },
    }

    [venue] = parse_overpass_response(_payload(node))

    assert venue.address == "Beispielstr. 1, 10115 Berlin"


def test_parse_uses_empty_address_without_address_tags():
    node = {"type": "node", "id": 1, "lat": 1.0, "lon": 2.0, "tags": {"name": "X"}}

    [venue] = parse_overpass_response(_payload(node))

    assert venue.address == ""


def test_parse_skips_elements_without_name():
    node = {"type": "node", "id": 1, "lat": 1.0, "lon": 2.0, "tags": {}}

    assert parse_overpass_response(_payload(node)) == []


def test_parse_skips_elements_without_coordinates():
    relation = {"type": "relation", "id": 1, "tags": {"name": "No Center"}}

    assert parse_overpass_response(_payload(relation)) == []


def test_parse_handles_missing_elements_key():
    assert parse_overpass_response({}) == []
