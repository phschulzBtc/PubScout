# Feature 008: Aktivitäts-Filter

## Status: draft

## User Story
Als Nutzer möchte ich nach bestimmten Aktivitäten filtern können, damit ich nur Bars sehe die meine gewünschte Aktivität anbieten.

## Akzeptanzkriterien
- [ ] Filter-Leiste über oder unter der Karte
- [ ] Filter als Chips/Toggles für jeden Aktivitätstyp
- [ ] Mehrfachauswahl möglich (z.B. Darts UND Billard)
- [ ] Keine Auswahl = alle Venues anzeigen
- [ ] Filter-Änderung löst sofort neuen API-Call aus
- [ ] Aktive Filter sind visuell hervorgehoben
- [ ] Anzahl der Ergebnisse wird angezeigt
- [ ] Widget-Tests für Filter-Komponente

## UI/UX
- Horizontale scrollbare Chip-Leiste
- Chips mit Activity-Icon und Name
- Ausgewählte Chips in Primärfarbe, unausgewählte in Grau
- Position: als BottomSheet/Drawer oder als Overlay über der Karte

## Technische Notizen
- Activities werden beim App-Start geladen (Provider)
- Filter-State in eigenem Riverpod Provider
- API-Call mit `activity_ids` Query-Parameter
