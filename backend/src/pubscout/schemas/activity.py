from pydantic import BaseModel


class ActivityResponse(BaseModel):
    name: str
    icon: str
    osm_tags: list[str]


class ActivitySummary(BaseModel):
    name: str
    icon: str
    details: str = ""
