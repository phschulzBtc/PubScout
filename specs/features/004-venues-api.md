# Feature 004: Venues API

## Status: draft
## Owner: Dev A (Backend)

## User Story
Als Frontend-Entwickler möchte ich Venues nach Standort und Aktivitäten filtern können, damit die Karte nur relevante Ergebnisse anzeigt.

## Akzeptanzkriterien
- [ ] GET /venues mit Query-Parametern: lat, lng, radius_km
- [ ] Optionaler Filter: activity_ids (Komma-separiert)
- [ ] Venues werden aus DB geladen (gecachte OSM-Daten)
- [ ] Fallback: Live-Abfrage über OSM Service wenn DB leer
- [ ] Geo-Distanz-Berechnung (Haversine oder SpatiaLite)
- [ ] Pagination (limit, offset)
- [ ] Response enthält Activities pro Venue
- [ ] Unit-Tests für alle Filter-Kombinationen

## API Contract

### GET /venues?lat=52.52&lng=13.405&radius_km=5&activity_ids=1,2&limit=50&offset=0
```json
{
  "total": 42,
  "venues": [
    {
      "id": 1,
      "name": "Bar Example",
      "latitude": 52.52,
      "longitude": 13.405,
      "address": "Beispielstr. 1, Berlin",
      "osm_id": "node/123456",
      "distance_km": 0.3,
      "activities": [
        { "id": 1, "name": "Darts", "icon": "darts" }
      ]
    }
  ]
}
```

## Technische Notizen
- Haversine-Formel für Distanzberechnung in Python (kein SpatiaLite für MVP)
- Pagination mit SQLModel select().offset().limit()
