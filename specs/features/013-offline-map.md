# Feature 013: Offline-Karte

## Status: draft

## User Story
Als Nutzer möchte ich die zuletzt angesehene Kartenregion auch offline sehen können, damit ich unterwegs ohne Internet navigieren kann.

## Akzeptanzkriterien
- [ ] Zuletzt geladene Map-Tiles werden lokal gecached
- [ ] Gecachte Venues sind offline verfügbar
- [ ] Offline-Indikator in der UI
- [ ] Graceful Degradation: App funktioniert mit eingeschränkter Funktionalität
- [ ] Cache-Größe begrenzt (z.B. 50MB)

## Technische Notizen
- flutter_map unterstützt Tile-Caching via `flutter_map_cache` Plugin
- Venue-Daten in lokaler SQLite/Hive Datenbank
- Service Worker für Web (PWA)
