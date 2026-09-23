# Feature 009: Venue-Detail-Ansicht

## Status: draft

## User Story
Als Nutzer möchte ich Details zu einer Bar sehen wenn ich auf einen Marker tippe, damit ich Adresse, Aktivitäten und Öffnungszeiten erfahre.

## Akzeptanzkriterien
- [ ] Tap auf Marker öffnet Detail-Ansicht
- [ ] Anzeige: Name, Adresse, Aktivitäten (mit Icons)
- [ ] Öffnungszeiten (falls in OSM-Daten vorhanden)
- [ ] Entfernung zum User-Standort
- [ ] "Route planen" Button (öffnet Google Maps / Apple Maps)
- [ ] Schließen-Button / Swipe-down zum Schließen
- [ ] Widget-Tests

## UI/UX
- Bottom Sheet das von unten einblendet
- Venue-Name als Überschrift
- Activity-Chips unter dem Namen
- Adresse mit Karten-Pin Icon
- Öffnungszeiten in lesbarem Format

## Technische Notizen
- Bottom Sheet mit DraggableScrollableSheet
- Öffnungszeiten aus OSM `opening_hours` Tag parsen
- Deep Link zu externen Karten-Apps via `url_launcher` Package
