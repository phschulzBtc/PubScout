# Feature 037: Native Mobile App (Android + iOS)

## Status: done

## Platform: mobile

## User Story
Als Nutzer möchte ich PubScout als native App auf meinem Android- oder iOS-Gerät nutzen können, damit ich unterwegs Bars mit Aktivitäten finden kann.

## Akzeptanzkriterien
- [x] Flutter Android-Projekt konfiguriert (android/)
- [x] Flutter iOS-Projekt konfiguriert (ios/)
- [x] Location-Permissions für Android (FINE + COARSE)
- [x] Location-Permissions für iOS (NSLocationWhenInUseUsageDescription)
- [x] Internet-Permission für Android
- [x] Cleartext-Traffic erlaubt für Entwicklung (Android)
- [x] Backend-URL konfigurierbar via `--dart-define=BACKEND_URL=...`
- [x] Standard-URL: Android Emulator → 10.0.2.2:8000, Web → localhost:8000
- [x] Geolocator für Android + iOS eingebunden
- [x] Alle bestehenden Features (Karte, Filter, Favoriten, i18n etc.) funktionieren auf Mobile

## Technische Notizen
- `flutter create --platforms android,ios .` generiert Runner-Projekte
- Backend-URL: `const String.fromEnvironment('BACKEND_URL')` → `--dart-define`
- Android: `android:usesCleartextTraffic="true"` für HTTP in Dev
- iOS: `NSLocationWhenInUseUsageDescription` in Info.plist
- Geolocator-Packages: `geolocator_android`, `geolocator_apple`
- LocationService hat bereits `kIsWeb`-Weiche für Platform-Handling

## Build-Befehle
```bash
# Android (Debug)
flutter run -d android

# Android (Release APK)
flutter build apk --dart-define=BACKEND_URL=https://api.pubscout.com

# iOS (Debug - nur auf macOS)
flutter run -d ios

# iOS (Release)
flutter build ios --dart-define=BACKEND_URL=https://api.pubscout.com

# Web (wie bisher)
flutter run -d chrome
```

## Platform-Tag Konvention
Alle Feature-Specs enthalten jetzt `## Platform: web | mobile | both`:
- **both** (Standard): Feature gilt für Web und Mobile
- **web**: Nur Web (z.B. PWA Support)
- **mobile**: Nur Mobile (z.B. Push Notifications, Pull-to-Refresh)
