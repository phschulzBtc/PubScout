# Feature 007: Karten-Ansicht

## Status: draft

## User Story
Als Nutzer möchte ich eine Karte mit Venue-Markern sehen, damit ich Bars und Kneipen in meiner Umgebung visuell finden kann.

## Akzeptanzkriterien
- [ ] flutter_map mit OpenStreetMap Tiles (bereits Grundlage in 001)
- [ ] User-Location ermitteln (Browser Geolocation API)
- [ ] Karte zentriert auf User-Position (Fallback: Berlin)
- [ ] Venue-Marker auf der Karte anzeigen
- [ ] Marker mit Activity-Icon oder farbiger Markierung
- [ ] Marker-Tap zeigt Venue-Name als Popup/Tooltip
- [ ] Karte lädt Venues beim Bewegen/Zoomen nach (Debounced)
- [ ] Loading-Indicator während Venues geladen werden
- [ ] Widget-Tests für Map-Screen

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
