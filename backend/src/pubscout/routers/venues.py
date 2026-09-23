import logging

from fastapi import APIRouter, Query, Request
from fastapi.responses import JSONResponse

from pubscout.config import settings
from pubscout.schemas.venue import VenueResponse
from pubscout.services.osm_service import (
    OsmService,
    OverpassApiError,
    OverpassRateLimitError,
    OverpassTimeoutError,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/venues", tags=["venues"])


def _get_osm_service(request: Request) -> OsmService:
    return request.app.state.osm_service


@router.get("", response_model=list[VenueResponse])
async def list_venues(
    request: Request,
    lat: float = Query(..., ge=-90, le=90, description="Latitude"),
    lng: float = Query(..., ge=-180, le=180, description="Longitude"),
    radius_km: float = Query(
        default=settings.default_search_radius_km,
        gt=0,
        le=50,
        description="Search radius in km",
    ),
    activities: str | None = Query(
        default=None,
        description="Comma-separated activity icons (e.g. darts,pool)",
    ),
):
    osm_service = _get_osm_service(request)
    activity_list = (
        [a.strip() for a in activities.split(",") if a.strip()]
        if activities
        else None
    )
    try:
        return await osm_service.fetch_venues(lat, lng, radius_km, activity_list)
    except OverpassRateLimitError:
        return JSONResponse(
            status_code=429,
            content={"detail": "Overpass API rate limit exceeded, please retry"},
        )
    except OverpassTimeoutError:
        logger.warning("Overpass API timed out for lat=%s lng=%s", lat, lng)
        return JSONResponse(
            status_code=504,
            content={"detail": "Overpass API timed out, please retry"},
        )
    except OverpassApiError as exc:
        logger.error("Overpass API error: %s", exc)
        return JSONResponse(
            status_code=502,
            content={"detail": "Overpass API unavailable, please retry"},
        )
