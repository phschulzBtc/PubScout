from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from pubscout.db.session import get_session
from pubscout.models.activity import Activity
from pubscout.schemas.activity import ActivityResponse

router = APIRouter(prefix="/activities", tags=["activities"])


@router.get("", response_model=list[ActivityResponse])
async def list_activities(session: AsyncSession = Depends(get_session)):
    result = await session.execute(select(Activity).order_by(Activity.name))
    return result.scalars().all()
