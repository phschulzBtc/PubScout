# Feature 004: Venues API

## Status: done
## Owner: Dev A (Backend)
## Depends on: 003

## User Story
Als Frontend-Entwickler möchte ich Venues nach Standort und Aktivitäten filtern können, damit die Karte nur relevante Ergebnisse anzeigt.

## Akzeptanzkriterien
- [x] GET /venues mit Query-Parametern: lat, lng, radius_km
- [x] Optionaler Filter: activities (Komma-separiert, z.B. "darts,pool")
- [x] Venues werden live von Overpass API abgefragt (kein DB-Cache im MVP)
- [x] Response enthält Activities pro Venue
- [x] Validierung der Query-Parameter (lat/lng Pflicht, sinnvolle Defaults)
- [x] Unit-Tests mit gemocktem OSM Service

## Query-Parameter
| Parameter | Pflicht | Regel | Default |
|---|---|---|---|
| `lat` | ja | -90 < lat < 90 | — |
| `lng` | ja | -180 ≤ lng ≤ 180 | — |
| `radius_km` | nein | 0 < radius_km ≤ 25 | 5 (`settings.default_search_radius_km`) |
| `activities` | nein | Komma-separierte **Icon-Kennungen** aus `/activities` (`darts`, `pool`, `quiz` …); Leerzeichen erlaubt; leer = kein Filter | alle |

## Fehler-Responses
| Status | Wann |
|---|---|
| 422 | Parameter fehlt/außerhalb des Bereichs, oder unbekannte Activity (`{"detail": "Unknown activities: Darts"}`) |
| 502 | Overpass-Fehler (5xx außer 504, kein JSON, Laufzeitfehler, Netzwerk) |
| 503 | Overpass Rate-Limit (HTTP 429) |
| 504 | Overpass Timeout (Client-Timeout, HTTP 504, `remark` „timed out“) |

## API Contract

### GET /venues?lat=52.52&lng=13.405&radius_km=5&activities=darts,pool
```json
[
  {
    "name": "Bar Example",
    "latitude": 52.52,
    "longitude": 13.405,
    "address": "Beispielstr. 1, Berlin",
    "osm_id": "node/123456",
    "activities": [
      { "name": "Darts", "icon": "darts" }
    ]
  }
]
```

## Technische Notizen
- Keine Pagination im MVP (Overpass liefert begrenzte Ergebnisse pro Radius)
- Kein `id` Feld — `osm_id` ist der eindeutige Identifier
- Kein `distance_km` im MVP (kann clientseitig berechnet werden)
- Activities in der Venue-Response enthalten KEIN `osm_tags` Feld (nur `name` + `icon`). `osm_tags` wird nur vom `/activities` Endpoint geliefert.

## Umsetzung
- `routers/venues.py`: Validierung per `Query(...)`-Constraints, Activity-Parsing + Prüfung gegen `find_activities_by_icons`, Mapping der `OverpassApiError`-Hierarchie auf HTTP-Status.
- `dependencies.py`: `create_osm_service(http_client)` baut `OsmService` mit `settings.overpass_api_url`; `get_osm_service()` liefert die **eine** Instanz aus `app.state` (per `Depends()`), damit alle Requests Connection-Pool und Rate-Limiter teilen.
- `main.py`: `lifespan` erzeugt den `httpx.AsyncClient` und schließt ihn beim Shutdown.
- `osm_service.py` (003): HTTP 504 von Overpass → `OverpassTimeoutError` (vorher generischer `OverpassApiError` → 502).
- Router nutzt keine DB mehr. `/activities` + DB-Code werden in 005 umgestellt bzw. entfernt (erledigt).

## Entscheidungen
- **Filter per Icon-Kennung, nicht per Name** (Entscheidung Dev A, 23.09.2026): stabil und URL-sicher, Namen sind Anzeige-Texte („Quiz/Trivia“). Unbekannte Werte → 422 statt stiller Ignorierung, damit Contract-Abweichungen sofort auffallen.
  ⚠️ **Hinweis an Dev B:** `ActivityFilterBar` und `MockApiClient` nutzen aktuell `activity.name` → echte API antwortet mit 422. Umstellung auf `activity.icon` nötig.
- **Max. Radius 25 km** (Entscheidung Dev A): deckt alle Frontend-Optionen (1/2/5/10/25 km) ab und schützt Overpass vor teuren Queries.
- **lat exklusiv ±90**: am Pol ist die Längengrad-Ausdehnung der Bounding-Box undefiniert (cos 90° = 0).
- Kein Retry bei vereinzelten Overpass-504 — Client bekommt 504 und kann neu laden; Caching (012) entschärft das. (Ursache der 504/429 ist das Overpass-Rate-Limit, nicht die Query-Form — siehe 003.)
- Große Radien sind langsam: 10 km über alle Activities dauerte live 21,6 s (Overpass-Timeout 25 s). Bei 25 km sind Timeouts wahrscheinlicher → ggf. mit Dev B abstimmen oder in 012 per Caching lösen.
- **Feste Fehlermeldungen** pro Status statt Upstream-Text (keine httpx-/Overpass-Interna an Clients); Originalfehler wird geloggt.

## Code Review (Subagent)
Keine kritischen Findings. Eingearbeitet: Lifespan-Verdrahtung als `osm_service_lifespan()` extrahiert und getestet (ASGITransport führt keinen Lifespan aus), kein globaler `app.state`-Seiteneffekt in Tests, Default-Radius gegen `settings` getestet, feste Fehlermeldungen statt Upstream-Text, Tests für Separator-/Whitespace-only-Filter.
Live verifiziert (23.09.2026): `activities=billiards` → 200 mit echten Berliner Venues; Overpass-504 → 504 „Venue data source timed out, retry later“; `activities=Darts` → 422.
