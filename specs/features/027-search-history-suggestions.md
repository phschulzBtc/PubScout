# Feature 027: Suchverlauf als Vorschläge

## Status: draft

## User Story
Als Nutzer möchte ich frühere Suchen als Vorschläge sehen, damit ich schnell zu bekannten Orten zurückkehren kann.

## Akzeptanzkriterien
- [ ] Letzte 5-10 Suchorte unter dem Suchfeld als Chips/Liste
- [ ] Tap auf einen Vorschlag zoomt zur gespeicherten Position
- [ ] Einzelne Einträge per Swipe/X löschbar
- [ ] "Verlauf löschen" Option
- [ ] Suchverlauf wird in SharedPreferences persistiert

## Technische Notizen
- `SearchHistoryService` existiert bereits
- UI: Dropdown unter der SearchBar oder als Chips-Row
- Daten: Ort-Name + Koordinaten speichern
