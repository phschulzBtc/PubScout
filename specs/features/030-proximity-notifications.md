# Feature 030: Nähe-Benachrichtigungen

## Status: draft

## User Story
Als Nutzer möchte ich benachrichtigt werden wenn ich in der Nähe einer Bar mit meiner Lieblingsaktivität bin, damit ich spontan vorbeischauen kann.

## Akzeptanzkriterien
- [ ] Opt-in Setting: "Benachrichtige mich bei Bars in der Nähe"
- [ ] Konfigurierbare Aktivitäts-Auswahl (z.B. nur Darts)
- [ ] Konfigurierbare Distanz (z.B. 200m, 500m)
- [ ] Notification zeigt Bar-Name, Aktivitäten und Entfernung
- [ ] Tap auf Notification öffnet PubScout mit Venue-Detail
- [ ] Cooldown: max 1 Notification pro Bar pro Tag
- [ ] Funktioniert nur bei aktiver Standort-Berechtigung "Immer"

## Technische Notizen
- Requires Background Location permission (mobile only, nicht Web)
- `geolocator` Geofencing oder `workmanager` für Background Tasks
- Lokale Notifications via `flutter_local_notifications`
- Feature nur für mobile App sinnvoll, nicht Web
- Braucht lokalen Venue-Cache (siehe Feature 029)
