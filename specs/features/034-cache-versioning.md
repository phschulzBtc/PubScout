# Feature 034: Cache-Versionierung

## Status: done

## User Story
Als Entwickler möchte ich dass der Backend-Cache nach Schema-Änderungen automatisch invalidiert wird, damit Nutzer keine veralteten Daten sehen.

## Akzeptanzkriterien
- [ ] Cache enthält eine Versions-Nummer
- [ ] Bei Schema-Änderung (neues Feld, geänderter Query) wird Version erhöht
- [ ] Alter Cache wird beim Start automatisch verworfen
- [ ] Kein manuelles Löschen der Cache-DB nötig
- [ ] Version wird in Cache-DB Metadaten-Tabelle gespeichert

## Technische Notizen
- `cache_service.py`: Schema-Version als Konstante
- Beim Start: gespeicherte Version lesen, bei Mismatch alle Einträge löschen
- Version in `CACHE_SCHEMA_VERSION = 2` Konstante (erhöhen bei jeder Änderung)
- Alternativ: Cache-Key enthält einen Hash der Overpass-Query-Struktur
