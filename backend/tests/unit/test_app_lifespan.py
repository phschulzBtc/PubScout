from httpx import ASGITransport, AsyncClient

from pubscout.main import app
from pubscout.services.osm_service import OsmService


async def test_app_lifespan_provides_osm_service_and_removes_it_on_shutdown():
    async with app.router.lifespan_context(app):
        assert isinstance(app.state.osm_service, OsmService)

    assert not hasattr(app.state, "osm_service")


async def test_app_starts_and_serves_requests_within_lifespan():
    async with app.router.lifespan_context(app):
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.get("/health")

    assert response.status_code == 200
