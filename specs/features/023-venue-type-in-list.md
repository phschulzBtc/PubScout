# Feature 023: Venue-Typ in Listeneintrag

## Status: draft

## User Story
Als Nutzer möchte ich in der Venue-Liste auf einen Blick sehen ob es eine Kneipe, Bar, Biergarten oder Nachtclub ist.

## Akzeptanzkriterien
- [ ] Subtitle zeigt Venue-Typ: z.B. "Bar · Friedrichstr. 1"
- [ ] Venue-Typ wird als deutsches Label angezeigt (Kneipe, Bar, Biergarten, Nachtclub)
- [ ] Bei fehlender Adresse: nur Venue-Typ ohne Trenner

## Technische Notizen
- `venue_list_panel.dart` Subtitle anpassen
- Label-Mapping existiert bereits in `venue_detail_sheet.dart` → in shared Utility extrahieren
