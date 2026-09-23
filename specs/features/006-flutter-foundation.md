# Feature 006: Flutter Grundgerüst

## Status: done
## Owner: Dev B (Frontend)
## Depends on: API Contract aus 004, 005 (Mock-Daten bis Backend fertig)

## User Story
Als Nutzer möchte ich eine funktionierende App-Shell mit Navigation und API-Anbindung, damit ich die App verwenden kann.

## Akzeptanzkriterien
- [x] App-Shell mit Material 3 Theme (bereits teilweise in 001)
- [x] API Client Service (Dio) mit Base-URL Konfiguration + ApiException
- [x] Venue Model (Dart) passend zum Backend-Response (mit ==, hashCode, defensive fromJson)
- [x] Activity Model (Dart) passend zum Backend-Response (mit ==, hashCode, defensive fromJson)
- [x] Riverpod Provider für Venues und Activities (NotifierProvider)
- [x] Error Handling im API Client (DioException → ApiException)
- [x] Loading States in Providern (FutureProvider AsyncValue)
- [x] Mock-API-Client für Entwicklung ohne laufendes Backend (mit Haversine Radius-Filter)
- [x] Widget-Tests (28 Tests: Models, MockClient, HttpClient, VenueFilter, App-Shell)

## UI/UX
- Material 3 Design
- PubScout Farbschema (Grün/Braun — Pub-Atmosphäre)
- Responsive: funktioniert auf Desktop und Mobile-Browser

## Technische Notizen
- Dio als HTTP Client (bereits als Dependency)
- Riverpod für State Management (bereits als Dependency)
- Models mit `fromJson`/`toJson` für API-Serialisierung
- Base URL über Environment/Constants konfigurierbar
