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

KILOMETERS_PER_DEGREE_LATITUDE = 111.32
OVERPASS_QUERY_TIMEOUT_SECONDS = 25
HTTP_TIMEOUT_MARGIN_SECONDS = 5
HTTP_REQUEST_TIMEOUT_SECONDS = (
    OVERPASS_QUERY_TIMEOUT_SECONDS + HTTP_TIMEOUT_MARGIN_SECONDS
)
OVERPASS_MIN_REQUEST_INTERVAL_SECONDS = 1.0
OVERPASS_RUNTIME_ERROR_MARKER = "runtime error"
OVERPASS_TIMEOUT_MARKER = "timed out"
VENUE_AMENITY_FILTER = '["amenity"~"^(pub|bar)$"]'
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

    @property
    def rate_limiter(self) -> RateLimiter:
        return self._rate_limiter

    async def query(self, overpass_query: str) -> dict:
        await self._rate_limiter.wait_for_slot()
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
        requested = _resolve_activities(activities)
        if not requested:
            return []

        # Try cache first
        if self._cache:
            cache_key = CacheService.make_key(lat, lng, radius_km, activities)
            cached = await self._cache.get(cache_key)
            if cached is not None:
                return [VenueResponse(**v) for v in cached]

        bounding_box = calculate_bounding_box(lat, lng, radius_km)
        payload = await self._overpass_client.query(
            build_overpass_query(bounding_box, requested)
        )
        venues = parse_overpass_response(payload)

        # Store in cache
        if self._cache:
            await self._cache.put(
                cache_key, [v.model_dump() for v in venues]
            )

        return venues


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
    bounding_box: BoundingBox, activities: list[ActivityDefinition]
) -> str:
    statements = "\n".join(
        f"  nwr{VENUE_AMENITY_FILTER}{_tag_filter(osm_tag)}"
        f"{bounding_box.to_overpass()};"
        for activity in activities
        for osm_tag in activity.osm_tags
    )
    return (
        f"[out:json][timeout:{OVERPASS_QUERY_TIMEOUT_SECONDS}];\n"
        f"(\n{statements}\n);\n"
        "out center tags;\n"
    )


def _tag_filter(osm_tag: str) -> str:
    key, value = osm_tag.split(OSM_TAG_SEPARATOR, maxsplit=1)
    return f'["{key}"~"(^|;) *{value} *(;|$)"]'


def parse_overpass_response(payload: dict) -> list[VenueResponse]:
    venues = (_parse_element(element) for element in payload.get("elements", []))
    return [venue for venue in venues if venue is not None]


def _parse_element(element: dict) -> VenueResponse | None:
    tags = element.get("tags", {})
    coordinates = _extract_coordinates(element)
    if "name" not in tags or coordinates is None:
        return None
    latitude, longitude = coordinates
    return VenueResponse(
        name=tags["name"],
        latitude=latitude,
        longitude=longitude,
        address=_format_address(tags),
        osm_id=f"{element['type']}/{element['id']}",
        activities=[
            ActivitySummary(name=activity.name, icon=activity.icon)
            for activity in match_activities(tags)
        ],
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
