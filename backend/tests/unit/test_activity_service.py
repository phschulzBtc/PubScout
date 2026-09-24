from pubscout.services.activity_service import (
    find_activities_by_icons,
    list_activities,
    match_activities,
)


def test_list_activities_contains_all_static_activities():
    icons = {activity.icon for activity in list_activities()}

    assert icons == {
        "billiards",
        "board_games",
        "darts",
        "foosball",
        "karaoke",
        "live_music",
        "poker",
        "quiz",
        "shuffleboard",
        "sport_tv",
        "table_tennis",
    }


def test_list_activities_is_sorted_by_name():
    names = [activity.name for activity in list_activities()]

    assert names == sorted(names)


def test_every_activity_has_osm_tags():
    for activity in list_activities():
        assert activity.osm_tags, f"{activity.name} has no osm_tags"


def test_match_activities_finds_activity_by_single_tag_value():
    matched = match_activities({"amenity": "pub", "sport": "darts"})

    assert [activity.icon for activity in matched] == ["darts"]


def test_match_activities_splits_semicolon_separated_values():
    matched = match_activities({"sport": "billiards;table_soccer"})

    assert {activity.icon for activity in matched} == {"billiards", "foosball"}


def test_match_activities_returns_empty_list_without_activity_tags():
    assert match_activities({"amenity": "bar", "name": "Plain Bar"}) == []


def test_match_activities_finds_karaoke():
    matched = match_activities({"karaoke": "yes"})

    assert [a.icon for a in matched] == ["karaoke"]


def test_match_activities_finds_live_music():
    matched = match_activities({"live_music": "yes"})

    assert [a.icon for a in matched] == ["live_music"]


def test_match_activities_finds_sport_tv():
    matched = match_activities({"sport_tv": "yes"})

    assert [a.icon for a in matched] == ["sport_tv"]


def test_match_activities_finds_television_as_sport_tv():
    matched = match_activities({"television": "yes"})

    assert [a.icon for a in matched] == ["sport_tv"]


def test_match_activities_finds_poker():
    matched = match_activities({"sport": "poker"})

    assert [a.icon for a in matched] == ["poker"]


def test_match_activities_billiards_includes_pool():
    matched = match_activities({"sport": "pool"})

    assert [a.icon for a in matched] == ["billiards"]


def test_find_activities_by_icons_returns_requested_activities():
    found = find_activities_by_icons(["darts", "billiards"])

    assert {activity.icon for activity in found} == {"darts", "billiards"}


def test_find_activities_by_icons_ignores_unknown_icons():
    found = find_activities_by_icons(["darts", "bowling"])

    assert [activity.icon for activity in found] == ["darts"]
