from sqlmodel import Field, Relationship, SQLModel

from pubscout.models.venue_activity import VenueActivity


class Activity(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(index=True, unique=True)
    icon: str = Field(default="")

    venues: list["Venue"] = Relationship(  # noqa: F821
        back_populates="activities",
        link_model=VenueActivity,
    )
