import logging
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status

from pubscout.config import settings
from pubscout.dependencies import get_osm_service
from pubscout.schemas.venue import VenueResponse
from pubscout.services.activity_service import find_activities_by_icons
from pubscout.services.osm_service import (
    OsmService,
    OverpassApiError,
    OverpassRateLimitError,
    OverpassTimeoutError,
)

MAX_LATITUDE = 90.0
MAX_LONGITUDE = 180.0
MAX_SEARCH_RADIUS_KM = 10.0
ACTIVITY_SEPARATOR = ","
ERROR_MESSAGES = {
    status.HTTP_502_BAD_GATEWAY: "Venue data source returned an error",
    status.HTTP_503_SERVICE_UNAVAILABLE: "Venue data source is busy, retry later",
    status.HTTP_504_GATEWAY_TIMEOUT: "Venue data source timed out, retry later",
}

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/venues", tags=["venues"])


@router.get("", response_model=list[VenueResponse])
async def list_venues(
    osm_service: Annotated[OsmService, Depends(get_osm_service)],
    lat: Annotated[float, Query(gt=-MAX_LATITUDE, lt=MAX_LATITUDE)],
    lng: Annotated[float, Query(ge=-MAX_LONGITUDE, le=MAX_LONGITUDE)],
    radius_km: Annotated[
        float, Query(gt=0, le=MAX_SEARCH_RADIUS_KM)
    ] = settings.default_search_radius_km,
    activities: Annotated[
        str | None, Query(description="Comma-separated activity icons, e.g. darts,pool")
    ] = None,
) -> list[VenueResponse]:
    requested = _parse_activities(activities)
    try:
        return await osm_service.fetch_venues(lat, lng, radius_km, requested)
    except OverpassApiError as error:
        logger.warning("Overpass request failed: %r", error)
        status_code = _status_for(error)
        raise HTTPException(status_code, detail=ERROR_MESSAGES[status_code]) from error


def _parse_activities(raw: str | None) -> list[str] | None:
    if raw is None:
        return None
    icons = [icon.strip() for icon in raw.split(ACTIVITY_SEPARATOR) if icon.strip()]
    if not icons:
        return None
    _reject_unknown(icons)
    return icons


def _reject_unknown(icons: list[str]) -> None:
    known = {activity.icon for activity in find_activities_by_icons(icons)}
    unknown = [icon for icon in icons if icon not in known]
    if unknown:
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=f"Unknown activities: {', '.join(unknown)}",
        )


def _status_for(error: OverpassApiError) -> int:
    if isinstance(error, OverpassTimeoutError):
        return status.HTTP_504_GATEWAY_TIMEOUT
    if isinstance(error, OverpassRateLimitError):
        return status.HTTP_503_SERVICE_UNAVAILABLE
    return status.HTTP_502_BAD_GATEWAY
