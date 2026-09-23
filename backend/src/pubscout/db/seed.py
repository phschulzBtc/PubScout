from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from pubscout.models.activity import Activity

DEFAULT_ACTIVITIES = [
    {"name": "Darts", "icon": "darts"},
    {"name": "Billard", "icon": "billiards"},
    {"name": "Kicker", "icon": "foosball"},
    {"name": "Pool", "icon": "pool"},
    {"name": "Brettspiele", "icon": "board_games"},
    {"name": "Tischtennis", "icon": "table_tennis"},
    {"name": "Shuffleboard", "icon": "shuffleboard"},
    {"name": "Quiz/Trivia", "icon": "quiz"},
]


async def seed_activities(session: AsyncSession) -> None:
    result = await session.execute(select(Activity))
    if result.scalars().first() is not None:
        return

    for data in DEFAULT_ACTIVITIES:
        session.add(Activity(**data))
    await session.commit()
