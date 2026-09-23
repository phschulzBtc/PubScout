from pydantic import BaseModel


class ActivityResponse(BaseModel):
    id: int
    name: str
    icon: str


class ActivitySummary(BaseModel):
    name: str
    icon: str
