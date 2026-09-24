import asyncio
import math
from dataclasses import dataclass

import httpx

from pubscout.schemas.activity import ActivitySummary
from pubscout.schemas.venue import VenueResponse
from pubscout.services.activity_service import (
    OSM_TAG_SEPARATOR,
    ActivityDefinition,
    find_activities_by_icons,
    list_activities,
    match_activities,
)
from pubscout.services.cache_service import CacheService
from pubscout.services.rate_limiter import RateLimiter
from pubscout.services.single_flight import SingleFlight

KILOMETERS_PER_DEGREE_LATITUDE = 111.32
OVERPASS_QUERY_TIMEOUT_SECONDS = 25
HTTP_TIMEOUT_MARGIN_SECONDS = 5
HTTP_REQUEST_TIMEOUT_SECONDS = (
    OVERPASS_QUERY_TIMEOUT_SECONDS + HTTP_TIMEOUT_MARGIN_SECONDS
)
OVERPASS_MIN_REQUEST_INTERVAL_SECONDS = 1.0
# Overpass grants few parallel slots per IP; parallel queries end in HTTP 429.
OVERPASS_MAX_CONCURRENT_REQUESTS = 1
OVERPASS_RUNTIME_ERROR_MARKER = "runtime error"
OVERPASS_TIMEOUT_MARKER = "timed out"
VENUE_AMENITY_FILTER = '["amenity"~"^(pub|bar|biergarten|nightclub)$"]'
VENUE_SET_NAME = "venues"
# Overpass rejects generic library user agents with HTTP 406.
USER_AGENT = "PubScout/0.1 (+https://github.com/phschulzBtc/PubScout)"


class OverpassApiError(Exception):
    """Overpass API request failed."""


class OverpassTimeoutError(OverpassApiError):
    """Overpass API did not answer in time."""


class OverpassRateLimitError(OverpassApiError):
    """Overpass API rejected the request due to rate limiting (HTTP 429)."""


class OverpassClient:
    def __init__(
        self,
        http_client: httpx.AsyncClient,
        api_url: str,
        rate_limiter: RateLimiter | None = None,
    ) -> None:
        self._http_client = http_client
        self._api_url = api_url
        self._rate_limiter = rate_limiter or RateLimiter(
            OVERPASS_MIN_REQUEST_INTERVAL_SECONDS
        )
        self._concurrency = asyncio.Semaphore(OVERPASS_MAX_CONCURRENT_REQUESTS)

    @property
    def rate_limiter(self) -> RateLimiter:
        return self._rate_limiter

    async def query(self, overpass_query: str) -> dict:
        async with self._concurrency:
            await self._rate_limiter.wait_for_slot()
            return await self._post(overpass_query)

    async def _post(self, overpass_query: str) -> dict:
        try:
            response = await self._http_client.post(
                self._api_url,
                data={"data": overpass_query},
                headers={"User-Agent": USER_AGENT},
                timeout=HTTP_REQUEST_TIMEOUT_SECONDS,
            )
        except httpx.TimeoutException as error:
            raise OverpassTimeoutError(str(error)) from error
        except httpx.HTTPError as error:
            raise OverpassApiError(str(error)) from error
        return _checked_json(response)


def _checked_json(response: httpx.Response) -> dict:
    if response.status_code == httpx.codes.TOO_MANY_REQUESTS:
        raise OverpassRateLimitError("Overpass API rate limit exceeded")
    if response.status_code == httpx.codes.GATEWAY_TIMEOUT:
        raise OverpassTimeoutError("Overpass API gateway timeout")
    if response.is_error:
        raise OverpassApiError(f"Overpass API returned {response.status_code}")
    try:
        payload = response.json()
    except ValueError as error:
        raise OverpassApiError("Overpass API returned no valid JSON") from error
    _raise_on_runtime_error(payload.get("remark", ""))
    return payload


def _raise_on_runtime_error(remark: str) -> None:
    if OVERPASS_RUNTIME_ERROR_MARKER not in remark:
        return
    if OVERPASS_TIMEOUT_MARKER in remark:
        raise OverpassTimeoutError(remark)
    raise OverpassApiError(remark)


class OsmService:
    def __init__(
        self,
        overpass_client: OverpassClient,
        cache: "CacheService | None" = None,
    ) -> None:
        self._overpass_client = overpass_client
        self._cache = cache
        self._single_flight: SingleFlight[list[VenueResponse]] = SingleFlight()

    @property
    def cache(self) -> "CacheService | None":
        return self._cache

    async def fetch_venues(
        self,
        lat: float,
        lng: float,
        radius_km: float,
        activities: list[str] | None = None,
    ) -> list[VenueResponse]:
        # When filtering, resolve requested activities; unknown icons → empty
        if activities:
            requested = _resolve_activities(activities)
            if not requested:
                return []
        else:
            requested = None
        if self._cache is None:
            return await self._query_overpass(lat, lng, radius_km, requested)
        cache_key = CacheService.make_key(lat, lng, radius_km, activities)
        # Identical concurrent requests share one cache lookup + Overpass query,
        # including its error, instead of queueing up duplicate queries.
        return await self._single_flight.run(
            cache_key,
            lambda: self._cached_query(cache_key, lat, lng, radius_km, requested),
        )

    async def _cached_query(
        self,
        cache_key: str,
        lat: float,
        lng: float,
        radius_km: float,
        activities: list[ActivityDefinition],
    ) -> list[VenueResponse]:
        cached = await self._cache.get(cache_key)
        if cached is not None:
            return [VenueResponse(**venue) for venue in cached]
        venues = await self._query_overpass(lat, lng, radius_km, activities)
        await self._cache.put(cache_key, [venue.model_dump() for venue in venues])
        return venues

    async def _query_overpass(
        self,
        lat: float,
        lng: float,
        radius_km: float,
        activities: list[ActivityDefinition],
    ) -> list[VenueResponse]:
        bounding_box = calculate_bounding_box(lat, lng, radius_km)
        payload = await self._overpass_client.query(
            build_overpass_query(bounding_box, activities)
        )
        return parse_overpass_response(payload)


def _resolve_activities(icons: list[str] | None) -> list[ActivityDefinition]:
    if icons is None:
        return list_activities()
    return find_activities_by_icons(icons)


@dataclass(frozen=True)
class BoundingBox:
    south: float
    west: float
    north: float
    east: float

    def to_overpass(self) -> str:
        return f"({self.south},{self.west},{self.north},{self.east})"


def calculate_bounding_box(
    latitude: float, longitude: float, radius_km: float
) -> BoundingBox:
    latitude_delta = radius_km / KILOMETERS_PER_DEGREE_LATITUDE
    kilometers_per_degree_longitude = KILOMETERS_PER_DEGREE_LATITUDE * math.cos(
        math.radians(latitude)
    )
    longitude_delta = radius_km / kilometers_per_degree_longitude
    return BoundingBox(
        south=latitude - latitude_delta,
        west=longitude - longitude_delta,
        north=latitude + latitude_delta,
        east=longitude + longitude_delta,
    )


def build_overpass_query(
    bounding_box: BoundingBox,
    activities: list[ActivityDefinition] | None = None,
) -> str:
    venues = f"nwr{bounding_box.to_overpass()}{VENUE_AMENITY_FILTER}"
    if activities:
        # Select pubs/bars in the box once, then filter that set with one
        # statement per tag key (10 km, all activities: 3.4 s instead of 14-16 s).
        body = f"{venues}->.{VENUE_SET_NAME};\n(\n{_activity_filters(activities)}\n);\n"
    else:
        # No filter: all pubs/bars in the area
        body = f"{venues};\n"
    return (
        f"[out:json][timeout:{OVERPASS_QUERY_TIMEOUT_SECONDS}];\n"
        f"{body}"
        "out center tags;\n"
    )


def _activity_filters(activities: list[ActivityDefinition]) -> str:
    return "\n".join(
        f'  nwr.{VENUE_SET_NAME}["{key}"~"(^|;) *({"|".join(values)}) *(;|$)"];'
        for key, values in _tag_values_by_key(activities).items()
    )


def _tag_values_by_key(activities: list[ActivityDefinition]) -> dict[str, list[str]]:
    grouped: dict[str, list[str]] = {}
    for activity in activities:
        for osm_tag in activity.osm_tags:
            key, value = osm_tag.split(OSM_TAG_SEPARATOR, maxsplit=1)
            values = grouped.setdefault(key, [])
            if value not in values:
                values.append(value)
    return grouped


def parse_overpass_response(payload: dict) -> list[VenueResponse]:
    venues = (_parse_element(element) for element in payload.get("elements", []))
    return [venue for venue in venues if venue is not None]


def _parse_element(element: dict) -> VenueResponse | None:
    tags = element.get("tags", {})
    coordinates = _extract_coordinates(element)
    if "name" not in tags or coordinates is None:
        return None
    latitude, longitude = coordinates
    matched = match_activities(tags)
    return VenueResponse(
        name=tags["name"],
        latitude=latitude,
        longitude=longitude,
        address=_format_address(tags),
        osm_id=f"{element['type']}/{element['id']}",
        venue_type=tags.get("amenity", "pub"),
        activities=[
            ActivitySummary(
                name=activity.name,
                icon=activity.icon,
                details=_activity_details(activity, tags),
            )
            for activity in matched
        ],
        description=tags.get("description", ""),
        opening_hours=tags.get("opening_hours", ""),
        website=tags.get("website", tags.get("contact:website", "")),
        phone=tags.get("phone", tags.get("contact:phone", "")),
        outdoor_seating=tags.get("outdoor_seating", "no").lower() == "yes",
        wheelchair=tags.get("wheelchair", ""),
    )


def _extract_coordinates(element: dict) -> tuple[float, float] | None:
    location = element if "lat" in element else element.get("center")
    if location is None:
        return None
    return location["lat"], location["lon"]


def _format_address(tags: dict[str, str]) -> str:
    street = _join_present(tags, ("addr:street", "addr:housenumber"))
    city = _join_present(tags, ("addr:postcode", "addr:city"))
    return ", ".join(part for part in (street, city) if part)


def _join_present(tags: dict[str, str], keys: tuple[str, ...]) -> str:
    return " ".join(tags[key] for key in keys if key in tags)


# Maps activity icon → (count_key, type_key) for extracting detail info.
_DETAIL_TAG_MAP: dict[str, tuple[str | None, str | None]] = {
    "billiards": ("billiards", "billiards:type"),
    "darts": ("darts", "darts:type"),
    "foosball": ("table_soccer", None),
    "table_tennis": ("table_tennis", None),
}


def _activity_details(
    activity: "ActivityDefinition", tags: dict[str, str]
) -> str:
    parts: list[str] = []
    mapping = _DETAIL_TAG_MAP.get(activity.icon)
    if mapping:
        count_key, type_key = mapping
        if count_key and count_key in tags:
            try:
                count = int(tags[count_key])
                if count > 0:
                    parts.append(f"{count}x")
            except ValueError:
                pass
        if type_key and type_key in tags:
            raw = tags[type_key]
            parts.append(raw.replace("_", " ").title())
    return " ".join(parts)
