# Feature 006: Flutter Grundgerüst

## Status: draft

## User Story
Als Nutzer möchte ich eine funktionierende App-Shell mit Navigation und API-Anbindung, damit ich die App verwenden kann.

## Akzeptanzkriterien
- [ ] App-Shell mit Material 3 Theme (bereits teilweise in 001)
- [ ] API Client Service (Dio) mit Base-URL Konfiguration
- [ ] Venue Model (Dart) passend zum Backend-Response
- [ ] Activity Model (Dart) passend zum Backend-Response
- [ ] Riverpod Provider für Venues und Activities
- [ ] Error Handling im API Client (Timeout, Network Error)
- [ ] Loading States in Providern
- [ ] Widget-Tests für App-Shell

## UI/UX
- Material 3 Design
- PubScout Farbschema (Grün/Braun — Pub-Atmosphäre)
- Responsive: funktioniert auf Desktop und Mobile-Browser

## Technische Notizen
- Dio als HTTP Client (bereits als Dependency)
- Riverpod für State Management (bereits als Dependency)
- Models mit `fromJson`/`toJson` für API-Serialisierung
- Base URL über Environment/Constants konfigurierbar
