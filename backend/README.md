# PubScout Backend

FastAPI-Backend das als Proxy zwischen dem Flutter-Frontend und der OpenStreetMap Overpass API dient. Liefert Venues (Bars/Kneipen) mit Aktivitaeten wie Darts, Billard, Kicker etc.

## Voraussetzungen

- Python 3.13+
- [uv](https://docs.astral.sh/uv/) (Package Manager)
- Oder: [Nix](https://nixos.org/) mit `nix develop` im Projekt-Root

## Starten

```bash
# Dependencies installieren
uv sync

# Dev-Server starten (Port 8000, Auto-Reload)
uv run uvicorn pubscout.main:app --reload --port 8000

# Alternativ mit Nix (empfohlen auf NixOS)
nix develop --impure --command bash -c "cd backend && uv sync && uv run uvicorn pubscout.main:app --reload --port 8000"
```

Der Server laeuft dann unter http://localhost:8000.

## API-Endpunkte

| Methode | Pfad | Beschreibung |
|---------|------|-------------|
| GET | `/health` | Health-Check mit Cache-Statistiken |
| GET | `/activities` | Alle verfuegbaren Aktivitaetstypen |
| GET | `/venues` | Venues in einem Gebiet suchen |

### GET /venues - Parameter

| Parameter | Typ | Pflicht | Beschreibung |
|-----------|-----|---------|-------------|
| `lat` | float | ja | Breitengrad (-90 bis 90) |
| `lng` | float | ja | Laengengrad (-180 bis 180) |
| `radius_km` | float | nein | Suchradius in km (Standard: 5, Max: 25) |
| `activities` | string | nein | Komma-getrennte Aktivitaets-Icons, z.B. `darts,pool` |

### Beispiele

```bash
# Venues in Berlin-Mitte, 5km Radius
curl "http://localhost:8000/venues?lat=52.52&lng=13.405"

# Nur Bars mit Darts und Billard, 2km Radius
curl "http://localhost:8000/venues?lat=52.52&lng=13.405&radius_km=2&activities=darts,billiards"

# Alle Aktivitaeten auflisten
curl "http://localhost:8000/activities"

# Health-Check mit Cache-Stats
curl "http://localhost:8000/health"
```

## OpenAPI-Dokumentation

Interaktive API-Docs unter http://localhost:8000/docs (Swagger UI).

## Konfiguration

Umgebungsvariablen (oder `.env`-Datei im `backend/`-Verzeichnis):

| Variable | Standard | Beschreibung |
|----------|---------|-------------|
| `OVERPASS_API_URL` | `https://overpass.openstreetmap.fr/api/interpreter` | Overpass API Endpunkt |
| `DEFAULT_SEARCH_RADIUS_KM` | `5.0` | Standard-Suchradius |
| `CACHE_DB_PATH` | `pubscout_cache.db` | Pfad zur SQLite-Cache-Datei |
| `CACHE_TTL_HOURS` | `24` | Cache-Gueltigkeitsdauer in Stunden |

## Tests

```bash
# Alle Tests ausfuehren
uv run pytest tests/ -v

# Nur Cache-Tests
uv run pytest tests/unit/test_cache_service.py -v
```

## Linting

```bash
# Mit ruff (auf NixOS via nix-shell)
nix-shell -p ruff --run "ruff check src/"

# Oder wenn ruff direkt verfuegbar
ruff check src/
```

## Projektstruktur

```
backend/
├── src/pubscout/
│   ├── main.py              # FastAPI App, Health-Endpunkt, CORS
│   ├── config.py            # Settings (Pydantic, .env)
│   ├── dependencies.py      # Dependency Injection (Lifespan)
│   ├── routers/
│   │   ├── venues.py        # GET /venues
│   │   └── activities.py    # GET /activities
│   ├── schemas/
│   │   ├── venue.py         # VenueResponse Model
│   │   └── activity.py      # ActivityResponse / ActivitySummary
│   └── services/
│       ├── osm_service.py       # Overpass API Client + Venue-Parsing
│       ├── activity_service.py  # Aktivitaets-Definitionen + OSM-Tag-Matching
│       ├── cache_service.py     # SQLite Venue-Cache (aiosqlite)
│       └── rate_limiter.py      # Overpass Rate-Limiting (1 Req/s)
├── tests/
│   └── unit/                # pytest Unit-Tests (77 Tests)
├── pyproject.toml           # Projekt-Config, Dependencies
└── uv.lock                  # Lockfile
```

## Architektur

```
Frontend  -->  FastAPI  -->  SQLite Cache  -->  Overpass API  -->  OpenStreetMap
               (Port 8000)    (24h TTL)         (Rate-Limited)
```

- **Kein eigener Datenbestand** -- alle Venue-Daten kommen aus OpenStreetMap via Overpass
- **Cache-First**: Anfragen werden zuerst gegen den SQLite-Cache geprueft
- **Rate-Limiting**: Max. 1 Request/Sekunde an die Overpass API
- **Fehlerbehandlung**: Overpass-Fehler werden als HTTP 502/503/504 weitergegeben
