# Feature 020: Venue-Liste nach Entfernung sortieren

## Status: done

## User Story
Als Nutzer möchte ich die Venue-Liste nach Entfernung zu meinem Standort sortiert sehen, damit ich die nächstgelegenen Bars zuerst finde.

## Akzeptanzkriterien
- [ ] Venues in der Desktop-Liste sind nach Entfernung zum User-Standort sortiert
- [ ] Entfernung wird als Subtitle angezeigt (z.B. "350 m · Friedrichstr. 1")
- [ ] Ohne Standort-Berechtigung: alphabetische Sortierung als Fallback
- [ ] Sortierung aktualisiert sich wenn der User seinen Standort neu ermittelt

## Technische Notizen
- Haversine-Distanz berechnen (existiert bereits in `venue_detail_sheet.dart`)
- Distanz-Berechnung in shared Utility extrahieren
- Sortierung im `filteredVenueProvider` oder eigenem Provider
