# Feature 028: Pull-to-Refresh auf Mobile

## Status: done

## User Story
Als mobiler Nutzer möchte ich die Karte durch Herunterziehen neu laden können, damit ich aktuelle Daten bekomme ohne die Karte verschieben zu müssen.

## Akzeptanzkriterien
- [ ] Pull-down-Geste am oberen Bildschirmrand löst Venue-Neuladen aus
- [ ] Standard-RefreshIndicator mit PubScout-Branding (grüne Farbe)
- [ ] Nur auf Mobile-Layout aktiv (nicht Desktop/Tablet)
- [ ] Ladeindikator ("Venues laden...") erscheint wie gewohnt

## Technische Notizen
- `RefreshIndicator` um den Mobile-Layout-Stack wrappen
- `ref.invalidate(venueProvider)` zum Neuladen
- Karten-Gestures dürfen nicht kollidieren
