# Feature 019: Venue-Anzahl in Filter-Chips

## Status: done

## User Story
Als Nutzer möchte ich in den Aktivitäts- und Venue-Typ-Filtern sehen, wie viele Treffer jeder Filter bringt, damit ich einschätzen kann ob sich ein Filter lohnt.

## Akzeptanzkriterien
- [ ] Aktivitäts-Chips zeigen Anzahl: z.B. "Darts (16)"
- [ ] Venue-Typ-Chips zeigen Anzahl: z.B. "Kneipe (87)"
- [ ] Counts aktualisieren sich beim Laden neuer Venues
- [ ] Bei aktivem Filter zeigt der Chip weiterhin die Gesamtzahl (nicht die gefilterte)

## Technische Notizen
- Counts aus `availableActivitiesProvider` / `availableVenueTypesProvider` ableiten
- Venues durchzählen pro Aktivität/Typ
- Rein Frontend, kein Backend-Change nötig
