import pytest

from pubscout.services.activity_service import (
    find_activities_by_icons,
    list_activities,
)
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


def test_build_overpass_query_restricts_to_pubs_and_bars_in_bounding_box():
    # Filter order within a statement does not matter: re-measured on
    # 2026-09-23, bbox first vs. last gave identical results and timings.
    darts = find_activities_by_icons(["darts"])

    query = build_overpass_query(BoundingBox(1.0, 2.0, 3.0, 4.0), darts)

    assert '["amenity"~"^(pub|bar|biergarten|nightclub)$"]' in query
    assert "(1.0,2.0,3.0,4.0)" in query


def test_build_overpass_query_filters_on_every_tag_of_requested_activities():
    darts = find_activities_by_icons(["darts"])

    query = build_overpass_query(BoundingBox(1.0, 2.0, 3.0, 4.0), darts)

    assert 'nwr.venues["leisure"~"(^|;) *(darts) *(;|$)"];' in query
    assert 'nwr.venues["sport"~"(^|;) *(darts) *(;|$)"];' in query
    assert "billiards" not in query


def test_build_overpass_query_selects_pubs_and_bars_in_bounding_box_only_once():
    # One statement per OSM tag re-scanned the whole box each time: 10 km with
    # all activities took 14-16 s vs. 3.4 s for this form (same results).
    query = build_overpass_query(BoundingBox(1.0, 2.0, 3.0, 4.0), list_activities())

    assert 'nwr(1.0,2.0,3.0,4.0)["amenity"~"^(pub|bar|biergarten|nightclub)$"]->.venues;' in query
    assert query.count("(1.0,2.0,3.0,4.0)") == 1


def test_build_overpass_query_groups_tag_values_per_key():
    query = build_overpass_query(BoundingBox(1.0, 2.0, 3.0, 4.0), list_activities())

    assert query.count("nwr.venues[") == 8
    assert (
        'nwr.venues["sport"~"(^|;) *'
        "(billiards|pool|darts|table_soccer|poker|shuffleboard|table_tennis)"
        ' *(;|$)"];'
    ) in query
    assert 'nwr.venues["leisure"~"(^|;) *(board_game|darts) *(;|$)"];' in query
    assert 'nwr.venues["quiz"~"(^|;) *(yes) *(;|$)"];' in query
    assert 'nwr.venues["karaoke"~"(^|;) *(yes) *(;|$)"];' in query
    assert 'nwr.venues["live_music"~"(^|;) *(yes) *(;|$)"];' in query
    assert 'nwr.venues["card_games"~"(^|;) *(yes) *(;|$)"];' in query
    assert 'nwr.venues["sport_tv"~"(^|;) *(yes) *(;|$)"];' in query
    assert 'nwr.venues["television"~"(^|;) *(yes) *(;|$)"];' in query


def test_build_overpass_query_without_filter_returns_all_pubs_and_bars():
    query = build_overpass_query(BoundingBox(1.0, 2.0, 3.0, 4.0), None)

    assert 'nwr(1.0,2.0,3.0,4.0)["amenity"~"^(pub|bar|biergarten|nightclub)$"]' in query
    assert "nwr.venues[" not in query
