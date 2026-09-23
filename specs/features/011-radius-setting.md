# Feature 011: Radius-Einstellung

## Status: draft

## User Story
Als Nutzer möchte ich den Suchradius anpassen können, damit ich mehr oder weniger Ergebnisse in meiner Umgebung sehe.

## Akzeptanzkriterien
- [ ] Slider oder Dropdown zur Radius-Auswahl
- [ ] Voreingestellte Werte: 1km, 2km, 5km, 10km, 25km
- [ ] Radius-Änderung löst neuen API-Call aus
- [ ] Visueller Radius-Kreis auf der Karte (optional)
- [ ] Einstellung wird lokal gespeichert
- [ ] Widget-Tests

## UI/UX
- Slider im Filter-Bereich oder als separates Control
- Aktueller Radius wird angezeigt (z.B. "5 km")
- Optionaler halbtransparenter Kreis auf der Karte

## Technische Notizen
- Default: 5km (aus Constants)
- SharedPreferences für persistente Einstellung
- Karten-Zoom passt sich dem Radius an
