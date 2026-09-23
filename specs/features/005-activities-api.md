# Feature 005: Activities API

## Status: done
## Owner: Dev A (Backend)
## Depends on: 003, 004

## User Story
Als Frontend-Entwickler möchte ich alle verfügbaren Aktivitätstypen abrufen können, damit ich Filter-Optionen in der UI anzeigen kann.

## Akzeptanzkriterien
- [x] GET /activities liefert alle Activities als statische Liste
- [x] Jede Activity hat: name, icon, osm_tags (welche OSM-Tags dazu gehören)
- [x] Sortierung nach Name
- [x] Unit-Tests
- [x] DB-Code entfernen (aus 003 verschoben): `db/`, `models/`, DB-Init/Seed im Lifespan, `database_url`, sqlmodel/alembic/aiosqlite

## API Contract

### GET /activities
```json
[
  { "name": "Billard", "icon": "billiards", "osm_tags": ["sport=billiards"] },
  { "name": "Brettspiele", "icon": "board_games", "osm_tags": ["leisure=board_game"] },
  { "name": "Darts", "icon": "darts", "osm_tags": ["leisure=darts", "sport=darts"] },
  { "name": "Kicker", "icon": "foosball", "osm_tags": ["sport=table_soccer"] },
  { "name": "Pool", "icon": "pool", "osm_tags": ["sport=pool"] },
  { "name": "Quiz/Trivia", "icon": "quiz", "osm_tags": ["quiz=yes"] },
  { "name": "Shuffleboard", "icon": "shuffleboard", "osm_tags": ["sport=shuffleboard"] },
  { "name": "Tischtennis", "icon": "table_tennis", "osm_tags": ["sport=table_tennis"] }
]
```

## Technische Notizen
- Statische Liste in `activity_service.py` — kein DB nötig
- osm_tags Feld ermöglicht dem OSM Service die richtigen Overpass-Queries zu bauen
- Kein POST im MVP — neue Activities erfordern Code-Änderung

## Umsetzung
- `routers/activities.py`: mappt `list_activities()` (bereits nach Name sortiert) auf `ActivityResponse {name, icon, osm_tags}` — kein `id` mehr.
- `icon` ist der Identifier für den `activities`-Filter von `GET /venues` (004).
- DB vollständig entfernt: `db/`, `models/`, `database_url` (config), DB-Fixtures in `tests/conftest.py`; Dependencies sqlmodel, alembic, aiosqlite (+ transitiv sqlalchemy, greenlet, mako, markupsafe) aus `pyproject.toml`/`uv.lock`.
- `main.py`: eigener `lifespan`, der nur noch `osm_service_lifespan()` einbindet. Ein Lifespan darf nichts außer `None`/State-Dict yielden — `osm_service_lifespan` liefert den httpx-Client (für Tests) und kann daher nicht direkt als App-Lifespan dienen.
- Neu: `test_app_lifespan.py` testet den echten App-Lifespan (ging vorher nicht, weil er die DB initialisierte).

## Entscheidungen / Befunde
- ~~Overpass-504-Bug gefunden und behoben: Bounding-Box hinter den Regex-Filtern → reproduzierbar HTTP 504~~ — **widerlegt** (Nachmessung 23.09.2026): Filter-Reihenfolge ist egal, Ursache war das Overpass-Rate-Limit. Die Umstellung auf `nwr(bbox)[...]` ist beim Merge von #3 ohnehin nicht auf `main` gelandet; der zugehörige Test wurde durch einen reihenfolge-unabhängigen ersetzt. Details in 003.
- Die lokale `backend/pubscout.db` (gitignored) wird nicht mehr genutzt und kann gelöscht werden.
- Die `.venv` enthält die entfernten Pakete noch, bis sie neu synchronisiert wird (`uv sync`) — funktional egal.

## Code Review (Subagent)
Keine kritischen/wichtigen Findings. Eingearbeitet: `osm_service_lifespan` entfernt `app.state.osm_service` beim Shutdown (kein Service mit geschlossenem Client bleibt zurück), inkl. Tests.
Nicht übernommen:
- *Sortier-Test ist redundant zum exakten Contract-Test* — bleibt als Dokumentation der Anforderung „Sortierung nach Name“.
- *`docs/claude/nixos.md` (greenlet/libstdc++-Abschnitt, SQLite in der Tool-Liste) und `flake.nix` (`LD_LIBRARY_PATH`-ShellHook) sind ohne SQLAlchemy veraltet* — geschützte Dateien der NixOS-Umgebung, nicht geändert. **Offen, nach Absprache aufräumen** (oder ab 012 wieder relevant).

Live verifiziert (23.09.2026): `GET /activities` liefert exakt den Contract; `GET /venues` läuft ohne DB (u. a. 10 km, alle Activities → 34 Venues).
