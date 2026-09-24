# Feature 024: Cluster-Popup mit Venue-Liste

## Status: done

## User Story
Als Nutzer möchte ich beim Klick auf einen Cluster-Marker eine Liste der enthaltenen Venues sehen, damit ich direkt eine Bar auswählen kann ohne erst reinzuzoomen.

## Akzeptanzkriterien
- [ ] Tap auf Cluster-Marker öffnet Popup/Bottom-Sheet mit Venue-Liste
- [ ] Liste zeigt Name, Venue-Typ-Icon und Adresse pro Venue
- [ ] Tap auf einen Eintrag öffnet die Venue-Detail-Ansicht und zoomt hin
- [ ] Cluster-Anzahl wird im Popup-Header angezeigt
- [ ] Bei mehr als ~10 Venues: scrollbare Liste
- [ ] Alternativ: Weiterhin Zoom-In bei sehr großen Clustern (>20)

## Technische Notizen
- Cluster-Daten sind bereits in `_clusterVenues()` gruppiert
- Bottom Sheet wiederverwenden (ähnlich `VenueDetailSheet`)
- Auf Desktop: Popup neben dem Cluster oder in der Seitenliste
