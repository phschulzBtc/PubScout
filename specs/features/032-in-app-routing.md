# Feature 032: Routenführung in der Karte

## Status: draft

## User Story
Als Nutzer möchte ich die Route zu einer Bar direkt in der App sehen, ohne zu Google Maps wechseln zu müssen.

## Akzeptanzkriterien
- [ ] "Route anzeigen" Button im Venue-Detail (zusätzlich zu "Route planen")
- [ ] Fußgänger-Route wird als Linie auf der Karte gezeichnet
- [ ] Geschätzte Gehzeit und Distanz angezeigt
- [ ] Route verschwindet wenn anderes Venue gewählt oder manuell geschlossen
- [ ] "Route planen" (extern) bleibt als Alternative erhalten

## Technische Notizen
- OSRM (Open Source Routing Machine) als Routing-Backend
- Kostenloser Public Server: `router.project-osrm.org`
- Oder eigener OSRM-Container im Docker Compose
- Route als Polyline auf der `flutter_map` zeichnen
- Profil: `foot-walking` für Fußgänger
