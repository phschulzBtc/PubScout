# Feature 001: Project Setup

## Status: done

## User Story
Als Entwickler möchte ich ein vollständig eingerichtetes Monorepo mit Backend und Frontend-Grundgerüst, damit ich Features spec-driven entwickeln kann.

## Akzeptanzkriterien
- [x] Git Repository initialisiert mit main Branch
- [x] .gitignore für Python, Dart, IDE-Dateien
- [x] Nix Flake für reproduzierbare Dev-Umgebung (Flutter, Python, Tools)
- [x] Backend: FastAPI Projekt mit uv, Health-Check Endpoint
- [x] Backend: Testinfrastruktur mit pytest, erster Test bestanden
- [x] Backend: Linting mit ruff konfiguriert
- [x] Monorepo-Verzeichnisstruktur (backend/, frontend/, specs/, scripts/)
- [x] Pre-commit Hooks konfiguriert (.pre-commit-config.yaml)
- [x] CLAUDE.md mit Projekt-Konventionen
- [ ] Frontend: Flutter Web Projekt erstellt (blocked: Flutter SDK via nix develop)
- [ ] Initial Commit auf main Branch

## Technische Notizen
- ruff über uv funktioniert nicht auf NixOS → `nix-shell -p ruff` Workaround
- SQLite als MVP-Datenbank (kein Docker nötig)
- Flutter SDK wird über flake.nix bereitgestellt, muss mit `nix develop` aktiviert werden
