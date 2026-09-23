from fastapi import APIRouter, Query, Request

from pubscout.config import settings
from pubscout.schemas.venue import VenueResponse
from pubscout.services.osm_service import OsmService

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
    return await osm_service.fetch_venues(lat, lng, radius_km, activity_list)
