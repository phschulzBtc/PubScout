# Feature 022: Dark Mode

## Status: draft

## User Story
Als Nutzer möchte ich einen Dark Mode nutzen können, damit die App abends in dunklen Bars angenehmer für die Augen ist.

## Akzeptanzkriterien
- [ ] `pubScoutDarkTheme` in `theme.dart` definiert
- [ ] System-Einstellung wird automatisch übernommen (`platformBrightness`)
- [ ] Manueller Toggle in Settings oder AppBar
- [ ] Karten-Tiles wechseln auf dunklen Stil (z.B. CartoDB Dark Matter)
- [ ] Alle Widgets (Chips, Cards, Bottom Sheet, Marker) sind im Dark Mode lesbar
- [ ] Einstellung wird in SharedPreferences gespeichert

## Technische Notizen
- `ThemeMode.system` als Default
- Dunkle Tile-URL: `https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png`
- Brand-Farben bleiben, Surfaces/Backgrounds werden dunkel
