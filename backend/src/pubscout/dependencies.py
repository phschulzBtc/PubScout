from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI, Request

from pubscout.config import settings
from pubscout.services.osm_service import OsmService, OverpassClient


def create_osm_service(http_client: httpx.AsyncClient) -> OsmService:
    return OsmService(OverpassClient(http_client, settings.overpass_api_url))


@asynccontextmanager
async def osm_service_lifespan(app: FastAPI) -> AsyncIterator[httpx.AsyncClient]:
    async with httpx.AsyncClient() as http_client:
        app.state.osm_service = create_osm_service(http_client)
        try:
            yield http_client
        finally:
            # Never leave a service with a closed HTTP client behind.
            del app.state.osm_service


def get_osm_service(request: Request) -> OsmService:
    # One shared instance (created in the app lifespan) so all requests share
    # the HTTP connection pool and the Overpass rate limiter.
    return request.app.state.osm_service
