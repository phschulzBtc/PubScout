# PubScout - CLAUDE.md

## Project Overview
PubScout finds bars/pubs with specific activities (darts, billiards, foosball, board games etc.) using OpenStreetMap data, displayed on an interactive map.

## Tech Stack
- **Backend**: Python 3.13 / FastAPI / SQLModel / SQLite+SpatiaLite (MVP)
- **Frontend**: Flutter Web (Dart) / flutter_map / Riverpod
- **Data Source**: OpenStreetMap / Overpass API
- **Dev Environment**: Nix Flake (`nix develop`)

## Commands

### Backend (run from `backend/`)
```bash
uv run uvicorn pubscout.main:app --reload   # Dev server (port 8000)
uv run pytest tests/ -v                      # Run tests
nix-shell -p ruff --run "ruff check src/"    # Lint (NixOS workaround)
nix-shell -p ruff --run "ruff check --fix src/"  # Auto-fix
```

### Frontend (run from `frontend/`)
```bash
flutter run -d chrome    # Web dev server
flutter test             # Unit/widget tests
dart analyze             # Static analysis
dart format .            # Format code
```

## Architecture

### Backend Structure (`backend/src/pubscout/`)
- `main.py` — FastAPI app entry point
- `config.py` — Settings via pydantic-settings
- `models/` — SQLModel database models
- `schemas/` — Pydantic request/response schemas
- `routers/` — API route handlers
- `services/` — Business logic (OSM client, venue service)
- `db/session.py` — Database session management

### Frontend Structure (`frontend/lib/`)
- `core/` — Theme, constants, shared utilities
- `models/` — Data models
- `services/` — API client, location service
- `providers/` — Riverpod state management
- `screens/` — UI screens

## Conventions

### CleanCode Rules
- SOLID principles throughout
- Single Responsibility per class/function
- Dependency Injection: FastAPI `Depends()`, Flutter Riverpod
- Meaningful names, no abbreviations
- Functions max ~20 lines
- No magic numbers — use constants
- Every service method has at least one unit test

### Git Workflow
- Branches: `main`, `develop`, `feature/NNN-desc`, `fix/NNN-desc`
- Spec-driven: write spec before code
- Feature specs in `specs/features/NNN-feature-name.md`

### API Design
- Backend runs on port **8000**
- OpenAPI docs at `/docs`
- Health check at `/health`

### Feature Workflow (Spec-Driven)
For each feature, follow this workflow:
1. **Spec schreiben** — `specs/features/NNN-feature-name.md` mit User Story, Akzeptanzkriterien, API Contract
2. **Feature-Branch** — `git checkout -b feature/NNN-description`
3. **Implementieren** — Code schreiben nach Spec
4. **Code Review** — Nach Abschluss einen Subagent als Code Reviewer starten:
   - Prüft CleanCode, SOLID, Architektur, Naming, Test-Coverage
   - Gibt konkretes Feedback mit Datei:Zeile Referenzen
   - Findings werden eingearbeitet bevor gemerged wird
5. **Spec aktualisieren** — Status auf `done`, Checkboxen abhaken
6. **Commit + Merge** — In develop mergen

### Automated Hooks (settings.local.json)
- **PostToolUse (Edit|Write)**: ruff auto-fix für Python-Dateien im backend/
- **Stop**: pytest läuft automatisch nach jeder Aufgabe

## KI-Team Workflow Regeln

### CLAUDE.md ist das zentrale Briefing
- Jeder Agent (auch in neuen Sessions) liest diese Datei zuerst
- Alles was Agents wissen müssen, gehört hier rein — nicht in den Chat
- Änderungen an Konventionen oder Architektur hier dokumentieren

### Specs sind der Vertrag
- Agents implementieren NUR was in der Spec steht
- Je präziser die Akzeptanzkriterien, desto besser das Ergebnis
- Keine eigenmächtigen Feature-Erweiterungen über die Spec hinaus
- Spec-Status immer aktuell halten: `draft` → `ready` → `in-progress` → `done`
- Alle Specs liegen in `specs/features/NNN-feature-name.md`

### Feature Branches isolieren Arbeit
- Jedes Feature bekommt einen eigenen Branch: `feature/NNN-description`
- Niemals direkt auf `main` oder `develop` committen
- Bei paralleler Arbeit (Backend + Frontend) separate Branches verwenden
- Merge erst nach bestandenem Code Review

### Review vor Merge — immer
- Nach jedem Feature einen Code-Reviewer-Subagent starten
- Review prüft: CleanCode, SOLID, Naming, Test-Coverage, Architektur
- Findings einarbeiten bevor gemerged wird
- Kein Merge ohne grüne Tests

### Memory-Files für Kontext-Übergabe
- Neue Sessions starten ohne Chat-Kontext
- Memory-Datei (`~/.claude/projects/.../memory/MEMORY.md`) enthält Projekt-Entscheidungen
- Bei wichtigen Entscheidungen Memory-File aktualisieren
- CLAUDE.md + Memory = komplettes Briefing für neue Sessions

### Kommunikation
- Bei Unklarheiten in der Spec: Rückfrage stellen, nicht raten
- Bei Architektur-Entscheidungen: User einbeziehen
- Technologie-Entscheidungen dokumentieren (warum X statt Y)

### NixOS Note
- `ruff` from uv doesn't work on NixOS (dynamic linking). Use `nix-shell -p ruff --run "..."` instead.
- Flutter/Dart via `nix develop` (flake.nix)
- `LD_LIBRARY_PATH` muss für greenlet gesetzt sein (flake.nix shellHook)
