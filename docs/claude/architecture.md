# Architecture

## Backend Structure (`backend/src/pubscout/`)
- `main.py` — FastAPI app entry point, lifespan for DB init + seed
- `config.py` — Settings via pydantic-settings (.env support)
- `models/` — SQLModel database models (Venue, Activity, VenueActivity)
- `schemas/` — Pydantic request/response schemas
- `routers/` — API route handlers (venues, activities)
- `services/` — Business logic (OSM client, venue service)
- `db/session.py` — Async DB session management (aiosqlite)
- `db/seed.py` — Default activity seed data

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
- `GET /activities` — List all activity types
- `GET /venues` — List venues with activities

## Database
- MVP: SQLite + aiosqlite (async)
- Later: PostgreSQL + PostGIS
- Models use SQLModel (SQLAlchemy + Pydantic combined)
