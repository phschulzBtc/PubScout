# Feature 003: OSM Data Service

## Status: draft
## Owner: Dev A (Backend)

## User Story
Als Backend-Entwickler möchte ich einen Service der Venue-Daten von OpenStreetMap via Overpass API abfragt, damit die App reale Bars und Kneipen mit Aktivitäten anzeigen kann.

## Akzeptanzkriterien
- [ ] Overpass API Client als eigener Service (`osm_service.py`)
- [ ] Overpass-Query für Bars/Pubs mit leisure/sport Tags (darts, billiards, etc.)
- [ ] Mapping von OSM-Tags auf PubScout Activity-Typen
- [ ] Geo-Bounding-Box basierte Abfrage (lat, lng, radius)
- [ ] Ergebnis-Parsing: OSM Node → Venue Model
- [ ] Fehlerbehandlung: Timeout, Rate-Limiting, API-Fehler
- [ ] Unit-Tests mit gemockter Overpass-Antwort

## API Contract
Interner Service, kein eigener Endpoint. Wird von `venue_service.py` aufgerufen.

```python
async def fetch_venues_from_osm(lat: float, lng: float, radius_km: float) -> list[Venue]
```

## Technische Notizen
- Overpass API URL: `https://overpass-api.de/api/interpreter`
- Relevante OSM-Tags: `leisure=darts`, `sport=billiards`, `sport=table_soccer`, `sport=table_tennis`, `leisure=board_game`
- httpx als async HTTP Client (bereits als Dependency vorhanden)
- Rate-Limiting beachten: max 1 Request pro Sekunde
