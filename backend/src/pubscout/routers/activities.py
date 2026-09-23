from fastapi import APIRouter

from pubscout.schemas.activity import ActivityResponse
from pubscout.services.activity_service import list_activities

router = APIRouter(prefix="/activities", tags=["activities"])


@router.get("", response_model=list[ActivityResponse])
async def get_activities() -> list[ActivityResponse]:
    return [
        ActivityResponse(
            name=activity.name, icon=activity.icon, osm_tags=list(activity.osm_tags)
        )
        for activity in list_activities()
    ]
