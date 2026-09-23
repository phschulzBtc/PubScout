# Feature 003: OSM Data Service

## Status: draft
## Owner: Dev A (Backend)

## User Story
Als Backend-Entwickler möchte ich einen Service der Venue-Daten von OpenStreetMap via Overpass API abfragt, damit die App reale Bars und Kneipen mit Aktivitäten anzeigen kann.

## Akzeptanzkriterien
- [ ] Overpass API Client als eigener Service (`osm_service.py`)
- [ ] Overpass-Query für Bars/Pubs mit leisure/sport Tags (darts, billiards, etc.)
- [ ] Mapping von OSM-Tags auf PubScout Activity-Typen (`activity_service.py`)
- [ ] Activities als statische Liste (kein DB) mit OSM-Tag-Mapping
- [ ] Geo-Bounding-Box basierte Abfrage (lat, lng, radius)
- [ ] Ergebnis-Parsing: OSM Node/Way → Pydantic VenueResponse Schema
- [ ] Fehlerbehandlung: Timeout, Rate-Limiting, API-Fehler
- [ ] Unit-Tests mit gemockter Overpass-Antwort
- [ ] DB-Code entfernen (models/, db/) — MVP braucht keine Datenbank

## API Contract
Interner Service, wird vom Venues-Router aufgerufen.

```python
async def fetch_venues(lat: float, lng: float, radius_km: float, activities: list[str] | None = None) -> list[VenueResponse]
```

## Technische Notizen
- Overpass API URL: `https://overpass-api.de/api/interpreter`
- Relevante OSM-Tags: `leisure=darts`, `sport=billiards`, `sport=table_soccer`, `sport=table_tennis`, `leisure=board_game`, `amenity=pub`, `amenity=bar`
- httpx als async HTTP Client (bereits als Dependency vorhanden)
- Rate-Limiting beachten: max 1 Request pro Sekunde
- Kein DB im MVP — Backend ist reiner OSM-Proxy
- Dependencies die entfallen: sqlmodel, alembic, aiosqlite
