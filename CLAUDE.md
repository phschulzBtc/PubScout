# PubScout

Web-App zum Finden von Bars/Kneipen mit Aktivitäten (Darts, Billard, Kicker, Brettspiele etc.) auf einer interaktiven Karte.

## Tech Stack
- **Backend**: Python 3.13 / FastAPI / SQLModel / SQLite (MVP)
- **Frontend**: Flutter Web (Dart) / flutter_map / Riverpod
- **Data**: OpenStreetMap / Overpass API
- **Dev**: Nix Flake (`nix develop`)

## Detail-Dokumentation
@include docs/claude/commands.md
@include docs/claude/architecture.md
@include docs/claude/workflow.md
@include docs/claude/conventions.md
@include docs/claude/nixos.md

## Quick Reference
- Backend port: **8000**, OpenAPI docs: `/docs`, Health: `/health`
- Feature-Specs: `specs/features/NNN-feature-name.md`
- Branches: `main` → `develop` → `feature/NNN-desc`
- Tests: `uv run pytest tests/ -v` (mit LD_LIBRARY_PATH auf NixOS)
- Lint: `nix-shell -p ruff --run "ruff check src/"`
