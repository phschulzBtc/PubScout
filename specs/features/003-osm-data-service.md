# Feature 003: OSM Data Service

## Status: done
## Owner: Dev A (Backend)

## User Story
Als Backend-Entwickler möchte ich einen Service der Venue-Daten von OpenStreetMap via Overpass API abfragt, damit die App reale Bars und Kneipen mit Aktivitäten anzeigen kann.

## Akzeptanzkriterien
- [x] Overpass API Client als eigener Service (`osm_service.py`)
- [x] Overpass-Query für Bars/Pubs mit leisure/sport Tags (darts, billiards, etc.)
- [x] Mapping von OSM-Tags auf PubScout Activity-Typen (`activity_service.py`)
- [x] Activities als statische Liste (kein DB) mit OSM-Tag-Mapping
- [x] Geo-Bounding-Box basierte Abfrage (lat, lng, radius)
- [x] Ergebnis-Parsing: OSM Node/Way → Pydantic VenueResponse Schema
- [x] Fehlerbehandlung: Timeout, Rate-Limiting, API-Fehler
- [x] Unit-Tests mit gemockter Overpass-Antwort
- [ ] ~~DB-Code entfernen (models/, db/)~~ — **verschoben nach 004/005** (siehe Entscheidungen)

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

## Umsetzung
- `activity_service.py`: statische `ACTIVITIES` (8 Einträge, `name`/`icon`/`osm_tags` wie Contract 005).
  `match_activities(tags)` erkennt Semikolon-Listen (`sport=billiards;darts`),
  `find_activities_by_icons(icons)` löst Filter-Identifier (= `icon`) auf, unbekannte werden ignoriert.
- `osm_service.py`:
  - `calculate_bounding_box()` — Radius → Bounding-Box (111,32 km/Breitengrad, Längengrad mit cos(lat) skaliert)
  - `build_overpass_query()` — ein `nwr`-Statement je OSM-Tag, jeweils auf `amenity=pub|bar` + Bounding-Box beschränkt, `out center tags` (Ways/Relations liefern Mittelpunkt)
  - `parse_overpass_response()` — Element → `VenueResponse`; Adresse aus `addr:*`; Elemente ohne `name` oder Koordinaten werden übersprungen
  - `OverpassClient` — POST mit eigenem User-Agent, Timeout; Fehler als `OverpassApiError` / `OverpassTimeoutError` / `OverpassRateLimitError` (HTTP 429)
  - `OsmService.fetch_venues()` — Signatur wie Contract, als Methode für Dependency Injection
- `rate_limiter.py`: `RateLimiter` erzwingt min. 1 s zwischen Requests (Clock/Sleep injizierbar für Tests)
- Schema: `VenueResponse` ohne `id`, `activities` als `ActivitySummary {name, icon}` (Contract 004)

## Entscheidungen
- **DB-Entfernung verschoben** (Entscheidung Dev A): `/activities` und `/venues` hängen noch an der DB. Der DB-Code wird entfernt, sobald 004/005 die Router auf die Services umstellen. Alternativen: Router in 003 minimal umverdrahten, oder 003–005 gemeinsam umsetzen.
- **User-Agent Pflicht**: Overpass antwortet mit HTTP 406 auf den Default-User-Agent von httpx (verifiziert) → `USER_AGENT = "PubScout/0.1 (+repo-URL)"`.
- **Filter ohne bekannte Activity** → leere Liste ohne Overpass-Request (statt Fehler). Validierung/Fehlermeldung für unbekannte Werte ist Sache des Routers (004).
- **Leere Filterliste** (`activities=[]`) → leere Liste; `None` → alle Activities.
- Öffentliche Overpass-Instanz antwortet sporadisch mit HTTP 504 (Live-Test 23.09.2026: ~1 von 4 Requests, unabhängig von der Kodierung) → `OverpassApiError`. Retry/Caching bewusst nicht in 003; Caching kommt mit 012.
- Overpass liefert Laufzeitfehler auch mit HTTP 200 und `remark: "runtime error: ..."` → wird als `OverpassTimeoutError` ("timed out") bzw. `OverpassApiError` gemeldet, damit das nicht als „keine Venues“ durchrutscht.
- Regex-Filter `(^|;) *value *(;|$)` toleriert Leerzeichen in Wertlisten (`sport=billiards; darts`), passend zu `match_activities`.

## Code Review (Subagent)
Eingearbeitet: JSON-/`remark`-Fehlerbehandlung, Rate-Limit-Konstante als Default im `OverpassClient`, Regex-Leerzeichen, benannte Timeout-Marge, Test für `activities=[]`, Nebenläufigkeitstest RateLimiter, httpx-Clients in Tests schließen.
Nicht übernommen:
- *Aufteilen von `osm_service.py` in 4 Module* — `docs/claude/architecture.md` legt `osm_service.py` als Client + Query-Builder + Transformer fest (geschützte Datei). Die Funktionen sind einzeln klein und single-purpose; Aufteilung ggf. nach Absprache.
- *`get_osm_service()`-Provider* — Router-Anbindung per `Depends()` gehört zu 004.
- *lat = ±90 / Längengrad-Clamping* — Parameter-Validierung ist Teil von 004 (lat/lng-Validierung im Router).
