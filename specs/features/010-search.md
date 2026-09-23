# Feature 010: Suchfunktion

## Status: done

## User Story
Als Nutzer möchte ich nach einem Ort oder einer Adresse suchen können, damit ich Bars in einer bestimmten Gegend finden kann.

## Akzeptanzkriterien
- [x] Suchfeld über der Karte (rounded TextField mit Search Icon)
- [x] Autocomplete-Vorschläge via Nominatim API (300ms Debounce)
- [x] Suche via Nominatim API mit User-Agent und Rate-Limiting
- [x] Auswahl zentriert Karte + lädt Venues für neuen Standort
- [x] Suchverlauf (letzte 5 Suchen via SharedPreferences)
- [x] History-Dropdown bei leerem Suchfeld + Fokus
- [x] Clear-Button zum Zurücksetzen
- [x] Widget-Tests (48 Tests gesamt)

## API Contract
Nominatim API (extern):
```
GET https://nominatim.openstreetmap.org/search?q=Berlin+Kreuzberg&format=json&limit=5
```

## Technische Notizen
- Nominatim Usage Policy beachten: max 1 Request pro Sekunde, User-Agent setzen
- Debounce auf Eingabe: 300ms
- SharedPreferences für Suchverlauf
