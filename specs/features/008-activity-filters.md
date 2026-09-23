# Feature 008: Aktivitäts-Filter

## Status: done
## Owner: Dev B (Frontend)
## Depends on: 006, 007

## User Story
Als Nutzer möchte ich nach bestimmten Aktivitäten filtern können, damit ich nur Bars sehe die meine gewünschte Aktivität anbieten.

## Akzeptanzkriterien
- [x] Filter-Leiste zwischen AppBar und Karte (horizontal scrollbar)
- [x] FilterChips mit Activity-Icon und Name
- [x] Mehrfachauswahl möglich (Toggle on/off)
- [x] Keine Auswahl = alle Venues anzeigen
- [x] Filter-Änderung aktualisiert venueFilterProvider → neuer API-Call
- [x] Aktive Filter visuell hervorgehoben (primaryContainer Farbe)
- [x] Anzahl Ergebnisse + aktive Filter in AppBar ("5 Venues (2 Filter)")
- [x] Widget-Tests: Chips rendern, select, deselect, multi-select (34 Tests gesamt)

## UI/UX
- Horizontale scrollbare Chip-Leiste
- Chips mit Activity-Icon und Name
- Ausgewählte Chips in Primärfarbe, unausgewählte in Grau
- Position: als BottomSheet/Drawer oder als Overlay über der Karte

## Technische Notizen
- Activities werden beim App-Start geladen (Provider)
- Filter-State in eigenem Riverpod Provider
- API-Call mit `activity_ids` Query-Parameter
