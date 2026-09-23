# Feature 016: PWA Support

## Status: draft

## User Story
Als Nutzer möchte ich die Web-App auf meinem Smartphone installieren können, damit ich sie wie eine native App verwenden kann.

## Akzeptanzkriterien
- [ ] Web App Manifest konfiguriert (Name, Icons, Theme-Color)
- [ ] Service Worker für Offline-Fähigkeit
- [ ] "Zum Startbildschirm hinzufügen" Prompt
- [ ] App-Icon und Splash-Screen
- [ ] Standalone Display-Modus (keine Browser-UI)
- [ ] Lighthouse PWA Score > 90

## UI/UX
- App-Icon: PubScout Logo in verschiedenen Größen
- Splash-Screen mit Logo und Ladebalken
- Theme-Color passend zum App-Design (Grün)

## Technische Notizen
- Flutter Web generiert bereits `manifest.json` und `index.html`
- Service Worker für Asset-Caching anpassen
- Icons in 192x192 und 512x512 (bereits vorhanden, müssen angepasst werden)
