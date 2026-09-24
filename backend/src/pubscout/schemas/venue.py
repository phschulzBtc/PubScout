from pydantic import BaseModel

from pubscout.schemas.activity import ActivitySummary


class VenueResponse(BaseModel):
    name: str
    latitude: float
    longitude: float
    address: str
    osm_id: str
    venue_type: str = "pub"
    activities: list[ActivitySummary]
    description: str = ""
    opening_hours: str = ""
    website: str = ""
    phone: str = ""
    outdoor_seating: bool = False
    wheelchair: str = ""
