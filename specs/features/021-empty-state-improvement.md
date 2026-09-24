# Feature 021: Verbesserter Leer-Zustand bei Filtern

## Status: draft

## User Story
Als Nutzer möchte ich bei leeren Suchergebnissen einen hilfreichen Hinweis sehen, damit ich weiß warum nichts angezeigt wird und was ich tun kann.

## Akzeptanzkriterien
- [ ] Wenn Filter aktiv und 0 Ergebnisse: "Keine Venues mit [Filtername] gefunden"
- [ ] Button "Filter entfernen" setzt alle Filter zurück
- [ ] Wenn kein Filter aktiv und 0 Ergebnisse: "Keine Venues im Umkreis von X km"
- [ ] Vorschlag: "Suchradius vergrößern?" mit Quick-Action
- [ ] Gilt für Karte (Overlay) und Desktop-Liste gleichermaßen

## Technische Notizen
- Empty-State-Widget als eigenes Widget extrahieren
- Zugriff auf `venueFilterProvider` für Kontext-Info
