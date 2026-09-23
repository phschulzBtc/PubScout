# Feature 011: Radius-Einstellung

## Status: done

## User Story
Als Nutzer möchte ich den Suchradius anpassen können, damit ich mehr oder weniger Ergebnisse in meiner Umgebung sehe.

## Akzeptanzkriterien
- [x] PopupMenuButton als Radius-Dropdown (Chip mit radar Icon)
- [x] Voreingestellte Werte: 1km, 2km, 5km, 10km, 25km
- [x] Radius-Änderung aktualisiert venueFilterProvider → neuer API-Call
- [x] Halbtransparenter Radius-Kreis auf der Karte (CircleLayer)
- [x] Einstellung wird via SharedPreferences lokal gespeichert
- [x] 48 Tests bestanden

## UI/UX
- Slider im Filter-Bereich oder als separates Control
- Aktueller Radius wird angezeigt (z.B. "5 km")
- Optionaler halbtransparenter Kreis auf der Karte

## Technische Notizen
- Default: 5km (aus Constants)
- SharedPreferences für persistente Einstellung
- Karten-Zoom passt sich dem Radius an
