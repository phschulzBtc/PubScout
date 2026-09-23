# Feature 005: Activities API

## Status: done
## Owner: Dev A (Backend)

## User Story
Als Frontend-Entwickler möchte ich alle verfügbaren Aktivitätstypen abrufen können, damit ich Filter-Optionen in der UI anzeigen kann.

## Akzeptanzkriterien
- [ ] GET /activities liefert alle Activities als statische Liste
- [ ] Jede Activity hat: name, icon, osm_tags (welche OSM-Tags dazu gehören)
- [ ] Sortierung nach Name
- [ ] Unit-Tests

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
