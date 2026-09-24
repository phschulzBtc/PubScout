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


def test_parse_extracts_description():
    node = {
        "type": "node",
        "id": 1,
        "lat": 1.0,
        "lon": 2.0,
        "tags": {"name": "Bar X", "description": "Gemütliche Eckkneipe"},
    }

    [venue] = parse_overpass_response(_payload(node))

    assert venue.description == "Gemütliche Eckkneipe"


def test_parse_extracts_opening_hours():
    node = {
        "type": "node",
        "id": 1,
        "lat": 1.0,
        "lon": 2.0,
        "tags": {"name": "Bar X", "opening_hours": "Mo-Fr 18:00-02:00"},
    }

    [venue] = parse_overpass_response(_payload(node))

    assert venue.opening_hours == "Mo-Fr 18:00-02:00"


def test_parse_extracts_website():
    node = {
        "type": "node",
        "id": 1,
        "lat": 1.0,
        "lon": 2.0,
        "tags": {"name": "Bar X", "website": "https://example.com"},
    }

    [venue] = parse_overpass_response(_payload(node))

    assert venue.website == "https://example.com"


def test_parse_extracts_contact_website_as_fallback():
    node = {
        "type": "node",
        "id": 1,
        "lat": 1.0,
        "lon": 2.0,
        "tags": {"name": "Bar X", "contact:website": "https://example.com"},
    }

    [venue] = parse_overpass_response(_payload(node))

    assert venue.website == "https://example.com"


def test_parse_extracts_phone():
    node = {
        "type": "node",
        "id": 1,
        "lat": 1.0,
        "lon": 2.0,
        "tags": {"name": "Bar X", "phone": "+49 30 12345"},
    }

    [venue] = parse_overpass_response(_payload(node))

    assert venue.phone == "+49 30 12345"


def test_parse_extracts_outdoor_seating():
    node = {
        "type": "node",
        "id": 1,
        "lat": 1.0,
        "lon": 2.0,
        "tags": {"name": "Bar X", "outdoor_seating": "yes"},
    }

    [venue] = parse_overpass_response(_payload(node))

    assert venue.outdoor_seating is True


def test_parse_extracts_wheelchair():
    node = {
        "type": "node",
        "id": 1,
        "lat": 1.0,
        "lon": 2.0,
        "tags": {"name": "Bar X", "wheelchair": "limited"},
    }

    [venue] = parse_overpass_response(_payload(node))

    assert venue.wheelchair == "limited"


def test_parse_extracts_darts_details():
    node = {
        "type": "node",
        "id": 1,
        "lat": 1.0,
        "lon": 2.0,
        "tags": {
            "name": "Dart Bar",
            "sport": "darts",
            "darts": "3",
            "darts:type": "steel",
        },
    }

    [venue] = parse_overpass_response(_payload(node))

    darts_activity = next(a for a in venue.activities if a.icon == "darts")
    assert darts_activity.details == "3x Steel"


def test_parse_extracts_billiards_details():
    node = {
        "type": "node",
        "id": 1,
        "lat": 1.0,
        "lon": 2.0,
        "tags": {
            "name": "Pool Hall",
            "sport": "billiards",
            "billiards": "2",
            "billiards:type": "pool",
        },
    }

    [venue] = parse_overpass_response(_payload(node))

    billiards = next(a for a in venue.activities if a.icon == "billiards")
    assert billiards.details == "2x Pool"


def test_parse_activity_details_empty_without_detail_tags():
    node = {
        "type": "node",
        "id": 1,
        "lat": 1.0,
        "lon": 2.0,
        "tags": {"name": "Bar X", "sport": "darts"},
    }

    [venue] = parse_overpass_response(_payload(node))

    assert venue.activities[0].details == ""
