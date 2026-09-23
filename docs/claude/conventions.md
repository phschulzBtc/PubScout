# Conventions

## CleanCode Rules
- SOLID principles throughout
- Single Responsibility per class/function
- Dependency Injection: FastAPI `Depends()`, Flutter Riverpod
- Meaningful names, no abbreviations
- Functions max ~20 lines
- No magic numbers — use constants
- Every service method has at least one unit test

## API Design
- Backend runs on port **8000**
- OpenAPI docs at `/docs`
- Health check at `/health`

## KI-Team Workflow Regeln

### CLAUDE.md ist das zentrale Briefing
- Jeder Agent liest diese Datei zuerst
- Alles was Agents wissen müssen, gehört hier rein — nicht in den Chat
- Änderungen an Konventionen oder Architektur hier dokumentieren

### Specs sind der Vertrag
- Agents implementieren NUR was in der Spec steht
- Keine eigenmächtigen Feature-Erweiterungen über die Spec hinaus
- Spec-Status immer aktuell halten

### Review vor Merge — immer
- Nach jedem Feature einen Code-Reviewer-Subagent starten
- Findings einarbeiten bevor gemerged wird
- Kein Merge ohne grüne Tests

### Memory-Files für Kontext-Übergabe
- Neue Sessions starten ohne Chat-Kontext
- Memory-Datei enthält Projekt-Entscheidungen
- Bei wichtigen Entscheidungen Memory-File aktualisieren

### Alles dokumentieren
- Jede Entscheidung dokumentieren: was wurde entschieden, warum, welche Alternativen gab es
- Technologie-Entscheidungen in der Spec oder in `docs/claude/` festhalten
- Architektur-Änderungen in `docs/claude/architecture.md` aktualisieren
- Neue Workarounds/Gotchas in `docs/claude/nixos.md` oder relevante Datei aufnehmen
- Wenn ein Feature fertig ist: Spec aktualisieren mit finalen technischen Notizen
- Keine undokumentierten Konventionen — was nicht aufgeschrieben ist, existiert nicht

### Kommunikation
- Bei Unklarheiten in der Spec: Rückfrage stellen, nicht raten
- Bei Architektur-Entscheidungen: User einbeziehen
