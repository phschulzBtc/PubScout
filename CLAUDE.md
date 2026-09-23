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

### NixOS Note
- `ruff` from uv doesn't work on NixOS (dynamic linking). Use `nix-shell -p ruff --run "..."` instead.
- Flutter/Dart via `nix develop` (flake.nix)
