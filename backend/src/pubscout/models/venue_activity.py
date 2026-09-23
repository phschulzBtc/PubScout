from sqlmodel import Field, SQLModel


class VenueActivity(SQLModel, table=True):
    __tablename__ = "venue_activity"

    venue_id: int = Field(foreign_key="venue.id", primary_key=True)
    activity_id: int = Field(foreign_key="activity.id", primary_key=True)
