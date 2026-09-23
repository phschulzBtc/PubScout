from pydantic import BaseModel

from pubscout.schemas.activity import ActivityResponse


class VenueResponse(BaseModel):
    id: int
    name: str
    latitude: float
    longitude: float
    address: str
    osm_id: str
    activities: list[ActivityResponse]
