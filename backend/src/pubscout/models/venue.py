from sqlmodel import Field, Relationship, SQLModel

from pubscout.models.venue_activity import VenueActivity


class Venue(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    latitude: float
    longitude: float
    address: str = Field(default="")
    osm_id: str = Field(default="", unique=True, index=True)

    activities: list["Activity"] = Relationship(  # noqa: F821
        back_populates="venues",
        link_model=VenueActivity,
    )
