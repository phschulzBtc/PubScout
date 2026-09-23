from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from pubscout.config import settings
from pubscout.dependencies import osm_service_lifespan
from pubscout.routers import activities, venues


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    async with osm_service_lifespan(app):
        yield


app = FastAPI(title=settings.app_name, version="0.1.0", lifespan=lifespan)

app.include_router(activities.router)
app.include_router(venues.router)


@app.get("/health")
async def health_check():
    return {"status": "ok", "app": settings.app_name}
