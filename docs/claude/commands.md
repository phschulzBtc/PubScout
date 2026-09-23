# Commands

## Backend (run from `backend/`)
```bash
uv run uvicorn pubscout.main:app --reload   # Dev server (port 8000)
uv run pytest tests/ -v                      # Run tests
nix-shell -p ruff --run "ruff check src/"    # Lint (NixOS workaround)
nix-shell -p ruff --run "ruff check --fix src/"  # Auto-fix
```

## Frontend (run from `frontend/`)
```bash
flutter run -d chrome    # Web dev server
flutter test             # Unit/widget tests
dart analyze             # Static analysis
dart format .            # Format code
```

## Tests mit LD_LIBRARY_PATH (NixOS)
```bash
cd backend
LD_LIBRARY_PATH=$(nix eval --raw nixpkgs#stdenv.cc.cc.lib)/lib:$LD_LIBRARY_PATH uv run pytest tests/ -v
```

Oder via nix develop:
```bash
nix develop --command bash -c "cd backend && uv run pytest tests/ -v"
```
