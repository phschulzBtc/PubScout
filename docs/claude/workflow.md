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
6. **Commit + Merge** — In develop mergen

## Git Branching
- `main` — Stable/Production
- `develop` — Integration Branch
- `feature/NNN-description` — Feature Branches
- `fix/NNN-description` — Bugfix Branches
- Niemals direkt auf `main` oder `develop` committen

## Spec Status Flow
`draft` → `ready` → `in-progress` → `done`

## Automated Hooks (settings.local.json)
- **PostToolUse (Edit|Write)**: ruff auto-fix für Python-Dateien im backend/
- **Stop**: pytest läuft automatisch nach jeder Aufgabe
