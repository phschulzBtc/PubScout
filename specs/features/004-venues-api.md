# Feature 004: Venues API

## Status: draft
## Owner: Dev A (Backend)
## Depends on: 003

## User Story
Als Frontend-Entwickler möchte ich Venues nach Standort und Aktivitäten filtern können, damit die Karte nur relevante Ergebnisse anzeigt.

## Akzeptanzkriterien
- [ ] GET /venues mit Query-Parametern: lat, lng, radius_km
- [ ] Optionaler Filter: activities (Komma-separiert, z.B. "darts,pool")
- [ ] Venues werden live von Overpass API abgefragt (kein DB-Cache im MVP)
- [ ] Response enthält Activities pro Venue
- [ ] Validierung der Query-Parameter (lat/lng Pflicht, sinnvolle Defaults)
- [ ] Unit-Tests mit gemocktem OSM Service

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
