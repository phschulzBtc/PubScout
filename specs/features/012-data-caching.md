# Feature 012: Daten-Caching

## Status: draft

## User Story
Als Nutzer möchte ich dass die App schnell reagiert und nicht bei jeder Kartenbewegung die Daten neu laden muss.

## Akzeptanzkriterien
- [ ] Backend cached OSM-Abfragen in SQLite
- [ ] Cache-Invalidierung nach konfiguriertem Zeitraum (z.B. 24h)
- [ ] Venues aus Cache werden bevorzugt geladen
- [ ] Nur bei Cache-Miss wird Overpass API abgefragt
- [ ] Cache-Statistik im Health-Endpoint
- [ ] Frontend cached letzte Venue-Liste lokal
- [ ] Unit-Tests für Cache-Logik

## Technische Notizen
- Backend: `cached_at` Timestamp auf Venue-Records
- Backend: Hintergrund-Job für Cache-Refresh (optional)
- Frontend: Riverpod cached automatisch Provider-State
- SQLite ist schnell genug für MVP-Caching
