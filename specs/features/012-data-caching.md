# Feature 012: Daten-Caching + Datenbank-Einführung

## Status: done
## Owner: TBD
## Depends on: 003, 004

## User Story
Als Nutzer möchte ich dass die App schnell reagiert und nicht bei jeder Anfrage die Overpass API abfragen muss.

## Akzeptanzkriterien
- [ ] Datenbank einführen (PostgreSQL + PostGIS oder SQLite + SpatiaLite)
- [ ] Venue-Daten aus Overpass werden in DB gecached
- [ ] Cache-Invalidierung nach konfiguriertem Zeitraum (z.B. 24h)
- [ ] API fragt zuerst Cache, dann Overpass als Fallback
- [ ] Cache-Statistik im Health-Endpoint
- [ ] DB-Migrations-Setup (Alembic)
- [ ] Unit-Tests für Cache-Logik

## Technische Notizen
- Dieses Feature führt die Datenbank ein die im MVP bewusst weggelassen wurde
- Wird relevant bei: vielen Nutzern (Overpass Rate-Limiting), Performance-Anforderungen, oder User-Features
- Entscheidung ob PostgreSQL oder SQLite wird zu diesem Zeitpunkt getroffen
- Die bestehenden DB-Models aus Feature 002 können als Basis reaktiviert werden
