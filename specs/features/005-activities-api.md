# Feature 005: Activities API

## Status: draft
## Owner: Dev A (Backend)

## User Story
Als Frontend-Entwickler möchte ich alle verfügbaren Aktivitätstypen abrufen können, damit ich Filter-Optionen in der UI anzeigen kann.

## Akzeptanzkriterien
- [ ] GET /activities liefert alle Activities (bereits implementiert in 002)
- [ ] POST /activities für Admin: neue Activity hinzufügen
- [ ] Activities haben Icon-Identifier für Frontend-Mapping
- [ ] Sortierung nach Name
- [ ] Unit-Tests

## API Contract

### GET /activities
```json
[
  { "id": 1, "name": "Billard", "icon": "billiards" },
  { "id": 2, "name": "Brettspiele", "icon": "board_games" }
]
```

### POST /activities (Admin)
```json
{ "name": "Bowling", "icon": "bowling" }
```
→ 201 Created

## Technische Notizen
- GET ist bereits in Feature 002 implementiert
- POST braucht später Auth — für MVP ohne Auth
- Icon-Mapping: String-Identifier den das Frontend zu Material Icons mapped
