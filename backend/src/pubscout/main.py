from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from pubscout.config import settings
from pubscout.routers import activities, venues
from pubscout.services.osm_service import OsmService, OverpassClient


@asynccontextmanager
async def lifespan(app: FastAPI):
    async with httpx.AsyncClient() as http_client:
        overpass_client = OverpassClient(http_client, settings.overpass_api_url)
        app.state.osm_service = OsmService(overpass_client)
        yield


app = FastAPI(title=settings.app_name, version="0.1.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET"],
    allow_headers=["*"],
)

app.include_router(activities.router)
app.include_router(venues.router)


@app.get("/health")
async def health_check():
    return {"status": "ok", "app": settings.app_name}
