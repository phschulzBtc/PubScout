from dataclasses import dataclass

OSM_TAG_SEPARATOR = "="
OSM_VALUE_SEPARATOR = ";"


@dataclass(frozen=True)
class ActivityDefinition:
    name: str
    icon: str
    osm_tags: tuple[str, ...]


ACTIVITIES: tuple[ActivityDefinition, ...] = (
    ActivityDefinition(
        "Billard/Pool", "billiards", ("sport=billiards", "sport=pool")
    ),
    ActivityDefinition("Brettspiele", "board_games", ("leisure=board_game",)),
    ActivityDefinition("Darts", "darts", ("leisure=darts", "sport=darts")),
    ActivityDefinition("Karaoke", "karaoke", ("karaoke=yes",)),
    ActivityDefinition("Kicker", "foosball", ("sport=table_soccer",)),
    ActivityDefinition("Live-Musik", "live_music", ("live_music=yes",)),
    ActivityDefinition(
        "Poker/Kartenspiele", "poker", ("sport=poker", "card_games=yes")
    ),
    ActivityDefinition("Quiz/Trivia", "quiz", ("quiz=yes",)),
    ActivityDefinition("Shuffleboard", "shuffleboard", ("sport=shuffleboard",)),
    ActivityDefinition("Tischtennis", "table_tennis", ("sport=table_tennis",)),
    ActivityDefinition(
        "TV/Sport", "sport_tv", ("sport_tv=yes", "television=yes")
    ),
)


def list_activities() -> list[ActivityDefinition]:
    return sorted(ACTIVITIES, key=lambda activity: activity.name)


def find_activities_by_icons(icons: list[str]) -> list[ActivityDefinition]:
    requested = set(icons)
    return [activity for activity in list_activities() if activity.icon in requested]


def match_activities(osm_tags: dict[str, str]) -> list[ActivityDefinition]:
    present_tags = _expand_tag_values(osm_tags)
    return [
        activity
        for activity in list_activities()
        if present_tags.intersection(activity.osm_tags)
    ]


def _expand_tag_values(osm_tags: dict[str, str]) -> set[str]:
    return {
        f"{key}{OSM_TAG_SEPARATOR}{value.strip()}"
        for key, raw_value in osm_tags.items()
        for value in raw_value.split(OSM_VALUE_SEPARATOR)
    }
