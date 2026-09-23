import pytest

from pubscout.services.activity_service import find_activities_by_icons
from pubscout.services.osm_service import (
    BoundingBox,
    build_overpass_query,
    calculate_bounding_box,
)

BERLIN_LATITUDE = 52.52
BERLIN_LONGITUDE = 13.405


def test_calculate_bounding_box_spans_radius_in_every_direction():
    box = calculate_bounding_box(BERLIN_LATITUDE, BERLIN_LONGITUDE, radius_km=1.0)

    assert box.south == pytest.approx(52.51102, abs=1e-5)
    assert box.north == pytest.approx(52.52898, abs=1e-5)
    assert box.west == pytest.approx(13.39024, abs=1e-5)
    assert box.east == pytest.approx(13.41976, abs=1e-5)


def test_build_overpass_query_requests_json_with_way_centers():
    query = build_overpass_query(BoundingBox(1.0, 2.0, 3.0, 4.0), activities=[])

    assert query.startswith("[out:json]")
    assert query.rstrip().endswith("out center tags;")


def test_build_overpass_query_puts_bounding_box_before_tag_filters():
    # Bounding box last makes Overpass evaluate the regex filters globally,
    # which reliably ends in HTTP 504 (verified live 2026-09-23).
    darts = find_activities_by_icons(["darts"])

    query = build_overpass_query(BoundingBox(1.0, 2.0, 3.0, 4.0), darts)

    assert 'nwr(1.0,2.0,3.0,4.0)["amenity"~"^(pub|bar)$"]["sport"' in query


def test_build_overpass_query_filters_on_every_tag_of_requested_activities():
    darts = find_activities_by_icons(["darts"])

    query = build_overpass_query(BoundingBox(1.0, 2.0, 3.0, 4.0), darts)

    assert '["leisure"~"(^|;) *darts *(;|$)"]' in query
    assert '["sport"~"(^|;) *darts *(;|$)"]' in query
    assert "billiards" not in query
