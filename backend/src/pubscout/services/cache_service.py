import json
import logging
import time

import aiosqlite

CACHE_SCHEMA_VERSION = 2

_CREATE_TABLE = """
CREATE TABLE IF NOT EXISTS venue_cache (
    cache_key TEXT PRIMARY KEY,
    response_json TEXT NOT NULL,
    created_at REAL NOT NULL
)
"""

_CREATE_META_TABLE = """
CREATE TABLE IF NOT EXISTS cache_meta (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
)
"""

_INSERT = """
INSERT OR REPLACE INTO venue_cache (cache_key, response_json, created_at)
VALUES (?, ?, ?)
"""

_SELECT = """
SELECT response_json, created_at FROM venue_cache WHERE cache_key = ?
"""

_COUNT = "SELECT COUNT(*) FROM venue_cache"

_DELETE_EXPIRED = "DELETE FROM venue_cache WHERE created_at < ?"

logger = logging.getLogger(__name__)


class CacheService:
    def __init__(self, db_path: str, ttl_hours: int = 24) -> None:
        self._db_path = db_path
        self._ttl_seconds = ttl_hours * 3600
        self._db: aiosqlite.Connection | None = None
        self._hits = 0
        self._misses = 0

    async def init(self) -> None:
        self._db = await aiosqlite.connect(self._db_path)
        await self._db.execute(_CREATE_META_TABLE)
        await self._db.execute(_CREATE_TABLE)
        await self._db.commit()
        await self._check_schema_version()

    async def _check_schema_version(self) -> None:
        cursor = await self._db.execute(
            "SELECT value FROM cache_meta WHERE key = 'schema_version'"
        )
        row = await cursor.fetchone()
        stored = int(row[0]) if row else 0
        if stored != CACHE_SCHEMA_VERSION:
            logger.info(
                "Cache schema version changed (%d → %d), clearing cache",
                stored,
                CACHE_SCHEMA_VERSION,
            )
            await self._db.execute("DELETE FROM venue_cache")
            await self._db.execute(
                "INSERT OR REPLACE INTO cache_meta"
                " (key, value) VALUES ('schema_version', ?)",
                (str(CACHE_SCHEMA_VERSION),),
            )
            await self._db.commit()

    async def close(self) -> None:
        if self._db:
            await self._db.close()
            self._db = None

    @staticmethod
    def make_key(
        lat: float, lng: float, radius_km: float, activities: list[str] | None
    ) -> str:
        # Round coordinates to ~100m precision to improve cache hits
        rlat = round(lat, 3)
        rlng = round(lng, 3)
        acts = ",".join(sorted(activities)) if activities else "*"
        return f"{rlat}:{rlng}:{radius_km}:{acts}"

    async def get(self, key: str) -> list[dict] | None:
        if not self._db:
            return None
        cursor = await self._db.execute(_SELECT, (key,))
        row = await cursor.fetchone()
        if row is None:
            self._misses += 1
            return None
        response_json, created_at = row
        if time.time() - created_at > self._ttl_seconds:
            self._misses += 1
            return None
        self._hits += 1
        return json.loads(response_json)

    async def put(self, key: str, venues: list[dict]) -> None:
        if not self._db:
            return
        await self._db.execute(_INSERT, (key, json.dumps(venues), time.time()))
        await self._db.commit()

    async def cleanup_expired(self) -> int:
        if not self._db:
            return 0
        cutoff = time.time() - self._ttl_seconds
        cursor = await self._db.execute(_DELETE_EXPIRED, (cutoff,))
        await self._db.commit()
        return cursor.rowcount

    async def stats(self) -> dict:
        entry_count = 0
        if self._db:
            cursor = await self._db.execute(_COUNT)
            row = await cursor.fetchone()
            entry_count = row[0] if row else 0
        total = self._hits + self._misses
        hit_rate = (self._hits / total * 100) if total > 0 else 0.0
        return {
            "entries": entry_count,
            "hits": self._hits,
            "misses": self._misses,
            "hit_rate_percent": round(hit_rate, 1),
        }
