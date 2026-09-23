# Architecture

## MVP: Backend als OSM-Proxy (kein DB)

Das Backend ist ein schlanker Proxy/Transformer:
```
Frontend → Backend → Overpass API → Transform → Frontend
```

Keine Datenbank im MVP. Activities sind eine statische Liste.
DB kommt später für User-Features (Bewertungen, Accounts, Caching).

## Backend Structure (`backend/src/pubscout/`)
- `main.py` — FastAPI app entry point
- `config.py` — Settings via pydantic-settings (.env support)
- `schemas/` — Pydantic request/response schemas
- `routers/` — API route handlers (venues, activities)
- `services/` — Business logic
  - `osm_service.py` — Overpass API Client, Query-Builder, Response-Transformer
  - `activity_service.py` — Statische Activity-Liste und OSM-Tag-Mapping

### Nicht mehr im MVP
- ~~`models/`~~ — DB Models entfallen
- ~~`db/`~~ — DB Session/Seed entfallen

## Frontend Structure (`frontend/lib/`)
- `main.dart` — Entry point with ProviderScope
- `app.dart` — MaterialApp with theme and routing
- `core/` — Theme, constants, shared utilities
- `models/` — Data models (Venue, Activity)
- `services/` — API client (Dio), location service
- `providers/` — Riverpod state management
- `screens/` — UI screens (MapScreen, VenueDetailScreen)

## API Endpoints
- `GET /health` — Health check
- `GET /activities` — Statische Liste aller Aktivitätstypen
- `GET /venues?lat=X&lng=Y&radius_km=Z&activities=darts,pool` — Venues via Overpass API

## Architektur-Entscheidung: Kein DB im MVP
**Entscheidung**: Backend ohne Datenbank, reiner OSM-Proxy
**Warum**: Alle Venue-Daten kommen von OSM. DB ist Overengineering solange es keine User-generierten Daten gibt.
**Wann DB**: Wenn Bewertungen, Accounts, serverseitige Favoriten oder Caching bei hoher Last benötigt werden.
