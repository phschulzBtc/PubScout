from pydantic import BaseModel

from pubscout.schemas.activity import ActivitySummary


class VenueResponse(BaseModel):
    name: str
    latitude: float
    longitude: float
    address: str
    osm_id: str
    activities: list[ActivitySummary]
