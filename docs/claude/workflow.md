# Feature Workflow (Spec-Driven)

## Per-Feature Workflow
1. **Spec lesen** — `specs/features/NNN-feature-name.md`
2. **Feature-Branch** — `git checkout -b feature/NNN-description`
3. **Implementieren** — Code schreiben nach Spec
4. **Code Review** — Subagent als Code Reviewer starten:
   - Prüft CleanCode, SOLID, Architektur, Naming, Test-Coverage
   - Gibt konkretes Feedback mit Datei:Zeile Referenzen
   - Findings einarbeiten bevor gemerged wird
5. **Spec aktualisieren** — Status auf `done`, Checkboxen abhaken
6. **Commit + Pull Request** — Merge nach `main` nur per PR:
   1. `git fetch origin` — **immer vorher pullen/fetchen**, damit Änderungen des anderen Devs bekannt sind; bei Konflikten `origin/main` in den Feature-Branch mergen und Tests erneut laufen lassen
   2. `git push -u origin feature/NNN-description`
   3. `gh pr create --base main` — PR-Beschreibung: Zusammenfassung, Testergebnis, Hinweise an den anderen Dev (z.B. Contract-Änderungen)
   4. Merge des PR auf GitHub; danach lokal `git switch main && git pull`

## Git Branching
- `main` — Integration + Stable (Feature-Branches werden per PR hierher gemergt)
- `feature/NNN-description` — Feature Branches (von aktuellem `main` abzweigen)
- `fix/NNN-description` — Bugfix Branches
- Niemals direkt auf `main` committen oder pushen — Änderungen nur per Pull Request
- Kein `develop`-Branch (Entscheidung 23.09.2026: zwei Devs, getrennte Verzeichnisse → Integration-Branch unnötig)

## Paralleles Arbeiten (2 Entwickler)

### Aufteilung nach Domäne
- **Dev A (Backend)**: Features die `backend/` betreffen
- **Dev B (Frontend)**: Features die `frontend/` betreffen
- Backend und Frontend leben in getrennten Verzeichnissen → keine Merge-Konflikte

### Geschützte Dateien
Diese Dateien nur nach Absprache ändern:
- `CLAUDE.md`, `docs/claude/*` — Projekt-Konventionen
- `specs/features/*` — nur die eigenen Specs bearbeiten
- `flake.nix` — Dev-Environment

### API Contract als Schnittstelle
- Specs definieren den API-Contract (Request/Response Format)
- Frontend baut gegen den Contract, nicht gegen den laufenden Server
- Frontend nutzt Mock-Daten bis das Backend fertig ist
- Integration (Mock → echte API) als gemeinsamer Sync-Punkt

### Phase 1 Aufteilung
| Dev A (Backend) | Dev B (Frontend) |
|---|---|
| 003 OSM Data Service | 006 Flutter Foundation (mit Mock-API) |
| 004 Venues API | 007 Map View |
| 005 Activities API | 008 Activity Filters |
| → Integration: Frontend auf echte API umstellen |

## Spec Status Flow
`draft` → `ready` → `in-progress` → `done`

## Automated Hooks (settings.local.json)
- **PostToolUse (Edit|Write)**: ruff auto-fix für Python-Dateien im backend/
- **Stop**: pytest läuft automatisch nach jeder Aufgabe
