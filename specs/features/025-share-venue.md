# Feature 025: Venue teilen

## Status: done

## User Story
Als Nutzer möchte ich eine Bar per Link mit Freunden teilen können, damit sie direkt dorthin navigieren können.

## Akzeptanzkriterien
- [ ] Share-Button im Venue-Detail-Sheet
- [ ] Generiert Deep-Link mit Koordinaten und OSM-ID (z.B. `pubscout.app/venue/node/123`)
- [ ] Fallback: Google Maps Link wenn Deep-Link nicht verfügbar
- [ ] Web Share API auf unterstützten Browsern, sonst Copy-to-Clipboard
- [ ] Geteilter Link öffnet PubScout und zoomt auf die Bar

## Technische Notizen
- `url_launcher` für Share, `share_plus` Package für native Share-Dialog
- Deep-Link-Routing mit `go_router` oder Flutter-eigenes URL-Handling
- Backend braucht keinen Endpoint — Link enthält alle Infos
