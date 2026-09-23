# Feature 010: Suchfunktion

## Status: draft

## User Story
Als Nutzer möchte ich nach einem Ort oder einer Adresse suchen können, damit ich Bars in einer bestimmten Gegend finden kann.

## Akzeptanzkriterien
- [ ] Suchfeld in der AppBar oder als FloatingActionButton
- [ ] Autocomplete-Vorschläge während der Eingabe
- [ ] Suche via Nominatim API (OpenStreetMap Geocoding)
- [ ] Auswahl eines Vorschlags zentriert die Karte auf den Ort
- [ ] Venues werden für den neuen Standort geladen
- [ ] Suchverlauf (letzte 5 Suchen, lokal gespeichert)
- [ ] Widget-Tests

## API Contract
Nominatim API (extern):
```
GET https://nominatim.openstreetmap.org/search?q=Berlin+Kreuzberg&format=json&limit=5
```

## Technische Notizen
- Nominatim Usage Policy beachten: max 1 Request pro Sekunde, User-Agent setzen
- Debounce auf Eingabe: 300ms
- SharedPreferences für Suchverlauf
