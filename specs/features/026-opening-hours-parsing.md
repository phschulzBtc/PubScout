# Feature 026: Öffnungszeiten-Parsing und "Jetzt geöffnet"

## Status: done

## User Story
Als Nutzer möchte ich sehen ob eine Bar gerade geöffnet hat, damit ich nicht vor verschlossener Tür stehe.

## Akzeptanzkriterien
- [ ] Badge "Geöffnet" (grün) oder "Geschlossen" (rot) im Venue-Detail und in der Liste
- [ ] Öffnungszeiten human-readable formatiert (nicht OSM-Rohformat)
- [ ] Nächste Öffnung/Schließung anzeigen: z.B. "Schließt um 02:00" / "Öffnet um 18:00"
- [ ] Fehlerhafte/unbekannte Formate: Rohtext als Fallback anzeigen
- [ ] Marker auf der Karte optional dimmen wenn geschlossen (User-Setting)

## Technische Notizen
- OSM `opening_hours` Format: https://wiki.openstreetmap.org/wiki/Key:opening_hours
- Dart Package `opening_hours_parser` oder eigener Parser
- Parsing im Frontend (kein Backend-Change)
- Zeitzonen beachten (User-Lokalzeit)
