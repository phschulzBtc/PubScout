# Feature 007: Karten-Ansicht

## Status: done
## Owner: Dev B (Frontend)
## Depends on: 006

## User Story
Als Nutzer möchte ich eine Karte mit Venue-Markern sehen, damit ich Bars und Kneipen in meiner Umgebung visuell finden kann.

## Akzeptanzkriterien
- [x] flutter_map mit OpenStreetMap Tiles
- [x] User-Location ermitteln (geolocator, Browser Geolocation API)
- [x] Karte zentriert auf User-Position (Fallback: Berlin)
- [x] Venue-Marker auf der Karte (grüne Kreise mit sports_bar Icon)
- [x] Marker-Tap öffnet BottomSheet mit Name, Adresse, Activity-Chips
- [x] Karte lädt Venues beim Bewegen nach (500ms Debounce)
- [x] Loading-Indicator ("Venues laden...") + Error-Card
- [x] Venue-Anzahl in AppBar
- [x] MyLocation FAB zum Zurückspringen
- [x] Widget-Tests (30 Tests gesamt)

## UI/UX
- Karte füllt den gesamten Bildschirm (unter AppBar)
- Venue-Marker sind deutlich sichtbar
- Cluster-Marker bei vielen Venues auf engem Raum (optional)
- Standort-Button zum Zurückspringen zur eigenen Position

## Technische Notizen
- `flutter_map` Package (Leaflet-basiert, bereits als Dependency)
- `latlong2` für Koordinaten
- Geolocation via `geolocator` Package (muss hinzugefügt werden)
- Debounce: 500ms nach letzter Karten-Bewegung bevor API-Call
