# Feature 036: Venue-Preloading beim Kartenverschieben

## Status: done

## User Story
Als Nutzer möchte ich dass Venues schon beim Verschieben der Karte vorgeladen werden, damit sie sofort sichtbar sind wenn ich aufhöre zu scrollen.

## Akzeptanzkriterien
- [ ] Beim Kartenverschieben wird der sichtbare Bereich als Preload-Zone berechnet
- [ ] Preload startet nach 200ms Pause (statt 500ms wie der aktuelle Debounce)
- [ ] Preloaded Venues werden gecached aber noch nicht angezeigt
- [ ] Beim endgültigen Stopp werden die gecachten Daten sofort angezeigt (Cache-Hit)
- [ ] Preload-Requests werden bei weiterer Bewegung abgebrochen

## Technische Notizen
- Zwei Debounce-Timer: 200ms für Preload, 500ms für Display
- Preload nutzt den bestehenden Cache (`CacheService`)
- `CancellationToken`-Pattern für abbrechbare Requests
- Preload-Bereich: aktueller Viewport + 50% Margin
- Achtung: Overpass Rate-Limiting (1 req/s) begrenzt den Nutzen
