import pytest

from pubscout.services.cache_service import CacheService

SAMPLE_VENUES = [
    {
        "name": "Test Bar",
        "latitude": 52.5,
        "longitude": 13.4,
        "address": "",
        "osm_id": "node/1",
        "activities": [],
    },
]


@pytest.fixture
async def cache(tmp_path):
    svc = CacheService(str(tmp_path / "test.db"), ttl_hours=1)
    await svc.init()
    yield svc
    await svc.close()


async def test_cache_miss_returns_none(cache):
    assert await cache.get("nonexistent") is None


async def test_put_and_get(cache):
    await cache.put("key1", SAMPLE_VENUES)
    result = await cache.get("key1")
    assert result == SAMPLE_VENUES


async def test_expired_entry_returns_none(cache):
    cache._ttl_seconds = 0  # expire immediately
    await cache.put("key1", SAMPLE_VENUES)
    assert await cache.get("key1") is None


async def test_stats_tracks_hits_and_misses(cache):
    await cache.put("key1", SAMPLE_VENUES)
    await cache.get("key1")  # hit
    await cache.get("missing")  # miss
    stats = await cache.stats()
    assert stats["hits"] == 1
    assert stats["misses"] == 1
    assert stats["entries"] == 1
    assert stats["hit_rate_percent"] == 50.0


async def test_cleanup_expired_removes_old_entries(cache):
    cache._ttl_seconds = 0
    await cache.put("key1", SAMPLE_VENUES)
    removed = await cache.cleanup_expired()
    assert removed == 1
    stats = await cache.stats()
    assert stats["entries"] == 0


async def test_make_key_rounds_coordinates():
    k1 = CacheService.make_key(52.5201, 13.4049, 5.0, None)
    k2 = CacheService.make_key(52.5204, 13.4051, 5.0, None)
    assert k1 == k2  # both round to 52.52:13.405


async def test_make_key_sorts_activities():
    k1 = CacheService.make_key(52.5, 13.4, 5.0, ["pool", "darts"])
    k2 = CacheService.make_key(52.5, 13.4, 5.0, ["darts", "pool"])
    assert k1 == k2
