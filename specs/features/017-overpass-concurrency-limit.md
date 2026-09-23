# Feature 017: Overpass Concurrency-Limit

## Status: done
## Owner: Dev A (Backend)
## Depends on: 003, 012

## User Story
Als Nutzer möchte ich keine „503 – Datenquelle ausgelastet“-Fehler sehen, wenn die Karte beim Start oder beim Verschieben mehrere Venue-Anfragen kurz hintereinander auslöst.

## Problem
Live am 23.09.2026: Das Frontend löst beim Start und bei Kartenbewegungen mehrere `GET /venues` kurz hintereinander aus (Default-Standort, User-Standort, Bewegungen). Overpass erlaubt pro IP nur wenige gleichzeitige Slots (overpass-api.de: 4); jede Query belegt einen Slot 5–20 s. Der bestehende `RateLimiter` (min. 1 s zwischen Request-*Starts*) begrenzt nicht die *gleichzeitig laufenden* Queries → Overpass antwortet mit HTTP 429 → Backend 503.

## Akzeptanzkriterien
- [x] Höchstens **eine** Overpass-Query gleichzeitig pro Backend-Instanz (`OVERPASS_MAX_CONCURRENT_REQUESTS = 1`)
- [x] Weitere Anfragen warten, bis die laufende fertig ist (Reihenfolge wie Eingang), der bestehende 1-s-Abstand bleibt
- [x] Identische, gleichzeitig laufende Anfragen teilen sich **eine** Ausführung (Cache-Lookup + Overpass-Query) — inkl. Fehler
- [x] Unit-Tests: max. 1 gleichzeitiger Request, identische parallele Anfragen → 1 Overpass-Request, geteilter Fehler

## Nicht im Scope
- Cache selbst — existiert bereits (012, `cache_service.py`)
- Kürzerer Connect-Timeout (Vorschlag 1 aus der Analyse) — bewusst nicht beauftragt
- Frontend-Änderungen (weniger Requests, Timeouts, Fehlermeldung) — Dev B

## Technische Notizen
- `asyncio.Semaphore` im `OverpassClient` um Rate-Limiter + HTTP-Request
- Trade-off: Warteschlange verlängert die Antwortzeit bei vielen *verschiedenen* Anfragen (Frontend-`receiveTimeout` 30 s) — lieber langsam als 429

## Umsetzung
- `osm_service.py`: `OverpassClient.query()` läuft unter `asyncio.Semaphore(OVERPASS_MAX_CONCURRENT_REQUESTS)`; `OsmService.fetch_venues()` leitet bei aktivem Cache über `SingleFlight` (Key = `CacheService.make_key`) an `_cached_query()` (Cache-Lookup → Overpass → `put`). Ohne Cache: direkt Overpass (nur Semaphore).
- `single_flight.py`: `SingleFlight[T].run(key, factory)` — gleichzeitige Aufrufe mit gleichem Key teilen einen `asyncio.Task` (Ergebnis oder Exception); `asyncio.shield`, damit ein abgebrochener Aufrufer die Ausführung für die anderen nicht abbricht; Key wird nach Abschluss vergessen.
- Fehler werden nicht gecacht (Exception vor `put`).
- Nebenbei: bestehende ruff-Fehler auf `main` behoben (`main.py` Import-Sortierung, `test_cache_service.py` ungenutzter Import).

## Entscheidungen
- **Single-Flight statt per-Key-Lock** (Code-Review): Ein Lock mit Cache-Recheck würde bei einem Fehler (429/Timeout) jede wartende identische Anfrage nacheinander erneut an Overpass schicken (N × 30 s). Single-Flight teilt auch den Fehler → 1 Request, alle bekommen sofort denselben Fehler.
- Hinweis: `CacheService` ohne `init()` ist ein No-Op — dann greift nur die Semaphore.

## Code Review (Subagent)
Keine blockierenden Findings. Eingearbeitet: Single-Flight gegen Fehler-Fan-out, Cache-Fixture mit sicherem `close()` in Tests. Mutationstest: Single-Flight deaktiviert → 4 Tests schlagen fehl.
Live verifiziert (23.09.2026, `overpass.openstreetmap.fr`): 3 identische + 1 andere parallele Anfrage → alle 200, 2 Overpass-Queries, kein 429.
