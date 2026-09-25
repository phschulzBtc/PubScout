# Feature 031: Bewertungen und Kommentare

## Status: deferred (requires backend database)

## User Story
Als Nutzer möchte ich Bars bewerten und Kommentare hinterlassen können, damit andere Nutzer von meinen Erfahrungen profitieren.

## Akzeptanzkriterien
- [ ] Sterne-Bewertung (1-5) pro Venue
- [ ] Freitext-Kommentar optional
- [ ] Durchschnittsbewertung im Venue-Detail und in der Liste
- [ ] Anzahl Bewertungen angezeigt
- [ ] Eigene Bewertung bearbeitbar/löschbar
- [ ] Sortierung der Venue-Liste nach Bewertung optional

## Technische Notizen
- Braucht Backend-Datenbank (siehe Roadmap Feature 012)
- REST API: `POST /venues/{osm_id}/ratings`, `GET /venues/{osm_id}/ratings`
- Anonyme Bewertungen (kein User-Auth im MVP) mit Device-ID
- Rate-Limiting gegen Spam
- Moderation-Strategie für Kommentare definieren
