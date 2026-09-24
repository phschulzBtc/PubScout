# Feature 035: Automatischer Retry bei Overpass-Timeout

## Status: draft

## User Story
Als Nutzer möchte ich dass die App bei einem Timeout automatisch nochmal versucht Daten zu laden, damit ich nicht manuell neu laden muss.

## Akzeptanzkriterien
- [ ] Bei Overpass-Timeout: 1x automatischer Retry nach 2 Sekunden
- [ ] Bei Overpass-Rate-Limit (429): Retry nach 5 Sekunden
- [ ] Maximal 1 Retry pro Request
- [ ] Retry-Indikator in der UI: "Erneuter Versuch..."
- [ ] Nach fehlgeschlagenem Retry: normale Fehlermeldung anzeigen

## Technische Notizen
- `OverpassClient.query()` um Retry-Logik erweitern
- Nur bei `OverpassTimeoutError` und `OverpassRateLimitError` retrien
- Nicht bei `OverpassApiError` (Server-Fehler) retrien
- Exponential Backoff nicht nötig bei nur 1 Retry
