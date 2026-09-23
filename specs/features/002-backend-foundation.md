# Feature 002: Backend Grundgerüst

## Status: done

## User Story
Als Entwickler möchte ich ein vollständiges Backend mit Datenbankmodellen für Venues und Activities, damit die API Daten speichern und abfragen kann.

## Akzeptanzkriterien
- [x] SQLModel Models: Venue (id, name, lat, lon, address, osm_id) mit Relation zu Activities
- [x] SQLModel Models: Activity (id, name, icon) als Stammdaten
- [x] Many-to-Many Beziehung: Venue <-> Activity (venue_activity Tabelle)
- [x] DB-Session Management mit async SQLite (aiosqlite)
- [x] DB wird beim App-Start automatisch erstellt (create_all)
- [x] Lifespan-Event für DB-Init und Seed-Daten
- [x] Seed-Daten: 8 vordefinierte Activities (Darts, Billard, Kicker, Pool, Brettspiele, Tischtennis, Shuffleboard, Quiz/Trivia)
- [x] GET /health gibt Status zurück
- [x] GET /activities liefert alle Activities
- [x] GET /venues liefert Venues mit ihren Activities
- [x] Pydantic Response-Schemas für Venues und Activities
- [x] Unit-Tests für alle Endpoints (6 Tests)
- [x] Seed-Idempotenz-Test

## API Contract

### GET /activities
```json
[
  { "id": 1, "name": "Darts", "icon": "darts" },
  { "id": 2, "name": "Billard", "icon": "billiards" }
]
```

### GET /venues
```json
[
  {
    "id": 1,
    "name": "Bar Example",
    "latitude": 52.52,
    "longitude": 13.405,
    "address": "Beispielstr. 1, Berlin",
    "osm_id": "node/123456",
    "activities": [
      { "id": 1, "name": "Darts", "icon": "darts" }
    ]
  }
]
```

## Technische Notizen
- SQLite DB-Datei: `backend/pubscout.db` (in .gitignore)
- Async Engine mit aiosqlite
- SQLModel für Models (kombiniert SQLAlchemy + Pydantic)
- FastAPI Lifespan für DB-Init
