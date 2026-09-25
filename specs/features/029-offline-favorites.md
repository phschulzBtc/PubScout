# Feature 029: Offline-Modus für Favoriten

## Status: done

## User Story
Als Nutzer möchte ich meine Favoriten auch ohne Internet sehen und dorthin navigieren können.

## Akzeptanzkriterien
- [ ] Favoriten-Daten (Name, Adresse, Koordinaten, Aktivitäten) lokal gespeichert
- [ ] Favoriten-Screen funktioniert offline
- [ ] "Route planen" Button öffnet auch offline die Karten-App (Koordinaten reichen)
- [ ] Offline-Banner zeigt an dass nur Favoriten verfügbar sind
- [ ] Karten-Tiles werden für Favoriten-Umgebung gecached

## Technische Notizen
- Favoriten sind bereits in SharedPreferences (`favorites_service.dart`)
- Tile-Caching: `flutter_map_tile_caching` Package
- Definierter Radius um jeden Favoriten cachen (z.B. 500m Tiles)
- Venue-Daten sind bereits im JSON-Format gespeichert
