# PubScout Frontend

Flutter Web App zum Finden von Bars und Kneipen mit Aktivitaeten (Darts, Billard, Kicker, Brettspiele etc.) auf einer interaktiven Karte.

## Voraussetzungen

- Flutter SDK 3.13+
- Dart SDK 3.13+
- Oder: [Nix](https://nixos.org/) mit `nix develop` im Projekt-Root
- Laufendes Backend auf Port 8000 (siehe `backend/README.md`)

## Starten

```bash
# Dependencies installieren
flutter pub get

# Dev-Server starten (Web)
flutter run -d web-server --web-port=3000
# Dann http://localhost:3000 im Browser oeffnen

# Alternativ mit Nix
nix develop --impure --command bash -c "cd frontend && flutter pub get && flutter run -d web-server --web-port=3000"

# Mit Mock-API (ohne Backend)
flutter run -d web-server --web-port=3000 --dart-define=USE_MOCK_API=true

# Auf Systemen mit Chrome als Flutter-Device (nicht WSL2)
flutter run -d chrome
```

## Build

```bash
# Produktions-Build (Web)
flutter build web

# Output liegt in build/web/
```

Der Build erzeugt automatisch einen Service Worker fuer PWA-Unterstuetzung (Offline-Faehigkeit, "Zum Startbildschirm hinzufuegen").

## Features

- **Interaktive Karte** -- OpenStreetMap mit Venue-Markern und Suchradius-Anzeige
- **Aktivitaets-Filter** -- Multi-Select Chips (Darts, Billard, Kicker, Pool, Brettspiele, Tischtennis, Quiz, Shuffleboard)
- **Suchradius** -- 1 / 2 / 5 / 10 / 25 km, persistent gespeichert
- **Ortssuche** -- Nominatim-Autocomplete mit Suchverlauf (letzte 5)
- **Venue-Details** -- Draggable Bottom Sheet mit Adresse, Aktivitaeten, Oeffnungszeiten, Entfernung, Route planen
- **Favoriten** -- Venues als Favorit speichern, Favoriten-Liste, hervorgehobene Marker auf der Karte
- **Responsive Design** -- Mobile (Bottom Sheet), Tablet (Side Panel), Desktop (Liste + Karte + Detail)
- **Offline-Modus** -- Gecachte Venues verfuegbar wenn Backend nicht erreichbar, Offline-Banner
- **PWA** -- Installierbar als Web-App, Offline-Caching via Service Worker

## Konfiguration

| Konstante | Datei | Standard | Beschreibung |
|-----------|-------|---------|-------------|
| `backendBaseUrl` | `lib/core/constants.dart` | `http://localhost:8000` | Backend-URL |
| `defaultSearchRadiusKm` | `lib/core/constants.dart` | `5.0` | Standard-Suchradius |
| `defaultLatitude/Longitude` | `lib/core/constants.dart` | Berlin (52.52, 13.405) | Startposition bei fehlendem GPS |
| `USE_MOCK_API` | Build-Flag | `false` | Mock-Daten statt echtem Backend |

## Analyse & Tests

```bash
# Dart Analyse (Lint)
dart analyze lib/

# Tests ausfuehren
flutter test
```

## Projektstruktur

```
frontend/lib/
├── main.dart                    # Einstiegspunkt
├── app.dart                     # MaterialApp mit Theme
├── core/
│   ├── constants.dart           # App-Konstanten (URLs, Defaults)
│   └── theme.dart               # Material 3 Theme (PubScout Green)
├── models/
│   ├── venue.dart               # Venue-Datenmodell
│   ├── activity.dart            # Activity-Datenmodell
│   └── venue_filter.dart        # Such-Filter (Lat/Lng/Radius/Activities)
├── providers/
│   ├── api_client_provider.dart     # API-Client (cached + mock-fähig)
│   ├── venue_provider.dart          # Venues laden (reaktiv auf Filter)
│   ├── activity_provider.dart       # Aktivitaeten laden
│   ├── location_provider.dart       # GPS-Standort
│   ├── favorites_provider.dart      # Favoriten-State
│   └── connectivity_provider.dart   # Online/Offline-Erkennung
├── services/
│   ├── api_client.dart              # HTTP-Client (Dio) zum Backend
│   ├── cached_api_client.dart       # Cache-Wrapper (Offline-Fallback)
│   ├── mock_api_client.dart         # Mock-Daten fuer Entwicklung
│   ├── api_exception.dart           # API-Fehlerklasse
│   ├── location_service.dart        # Geolocator-Wrapper
│   ├── nominatim_service.dart       # OSM Geocoding (Ortssuche)
│   ├── search_history_service.dart  # Suchverlauf (SharedPreferences)
│   ├── favorites_service.dart       # Favoriten-Persistenz
│   └── venue_cache_service.dart     # Venue-Cache (Offline)
├── screens/
│   ├── map_screen.dart              # Hauptscreen (Karte + responsive Layout)
│   └── favorites_screen.dart        # Favoriten-Liste
└── widgets/
    ├── search_bar_widget.dart       # Ortssuche mit Autocomplete
    ├── activity_filter_bar.dart     # Aktivitaets-Chips
    ├── radius_selector.dart         # Radius-Dropdown
    ├── venue_detail_sheet.dart      # Venue-Detail (Bottom Sheet / Side Panel)
    ├── venue_list_panel.dart        # Venue-Liste (Desktop)
    └── offline_banner.dart          # Offline-Indikator
```

## Architektur

```
User  -->  MapScreen (LayoutBuilder)
               |
               ├── SearchBar (Nominatim API)
               ├── ActivityFilterBar
               ├── RadiusSelector
               |
               └── FlutterMap
                    ├── TileLayer (OSM)
                    ├── CircleLayer (Suchradius)
                    └── MarkerLayer (Venues)

State: Riverpod (Provider Pattern)
  VenueFilter --> VenueProvider --> CachedApiClient --> Backend API
                                        |
                                        └── VenueCacheService (Offline-Fallback)
```

## Tech Stack

| Paket | Zweck |
|-------|-------|
| `flutter_map` | Karten-Rendering (OpenStreetMap) |
| `flutter_riverpod` | State Management |
| `dio` | HTTP-Client |
| `geolocator` | GPS-Standort |
| `shared_preferences` | Lokale Persistenz (Favoriten, Suchverlauf, Cache) |
| `url_launcher` | Google Maps Navigation |
| `flutter_svg` | Logo-Rendering |
| `latlong2` | Koordinaten-Handling |
