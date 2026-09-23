from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from sqlmodel import select

from pubscout.db.session import get_session
from pubscout.models.venue import Venue
from pubscout.schemas.venue import VenueResponse

router = APIRouter(prefix="/venues", tags=["venues"])


@router.get("", response_model=list[VenueResponse])
async def list_venues(session: AsyncSession = Depends(get_session)):
    result = await session.execute(
        select(Venue).options(selectinload(Venue.activities))
    )
    return result.scalars().all()
