# Feature 009: Venue-Detail-Ansicht

## Status: done

## User Story
Als Nutzer möchte ich Details zu einer Bar sehen wenn ich auf einen Marker tippe, damit ich Adresse, Aktivitäten und Öffnungszeiten erfahre.

## Akzeptanzkriterien
- [x] Tap auf Marker öffnet DraggableScrollableSheet
- [x] Anzeige: Name, Adresse, Activity-Chips
- [x] Öffnungszeiten (falls vorhanden, mit access_time Icon)
- [x] Entfernung zum User-Standort (Haversine, m/km Format)
- [x] "Route planen" Button (öffnet Google Maps Directions)
- [x] Drag-Handle + Swipe-down zum Schließen
- [x] Widget-Tests (7 Tests für VenueDetailSheet, 41 gesamt)

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
