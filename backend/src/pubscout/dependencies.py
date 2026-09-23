from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI, Request

from pubscout.config import settings
from pubscout.services.cache_service import CacheService
from pubscout.services.osm_service import OsmService, OverpassClient


def create_osm_service(
    http_client: httpx.AsyncClient, cache: CacheService | None = None
) -> OsmService:
    return OsmService(
        OverpassClient(http_client, settings.overpass_api_url), cache=cache
    )


@asynccontextmanager
async def osm_service_lifespan(app: FastAPI) -> AsyncIterator[httpx.AsyncClient]:
    cache = CacheService(settings.cache_db_path, settings.cache_ttl_hours)
    await cache.init()
    try:
        async with httpx.AsyncClient() as http_client:
            app.state.osm_service = create_osm_service(http_client, cache=cache)
            app.state.cache_service = cache
            try:
                yield http_client
            finally:
                # Never leave services with a closed client/cache behind.
                del app.state.osm_service
                del app.state.cache_service
    finally:
        await cache.close()


def get_osm_service(request: Request) -> OsmService:
    return request.app.state.osm_service


def get_cache_service(request: Request) -> CacheService:
    return request.app.state.cache_service
