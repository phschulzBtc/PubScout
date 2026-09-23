# NixOS Notes

## Dev Environment
- Alle Tools via `nix develop` (flake.nix): Flutter, Dart, Python, uv, ruff, jq, pre-commit, SQLite
- `.envrc` mit `use flake` für direnv-Integration

## Bekannte Probleme

### ruff aus uv funktioniert nicht
Dynamisch gelinkte Binaries aus pip/uv laufen nicht auf NixOS.
**Workaround**: `nix-shell -p ruff --run "ruff check ..."`

### greenlet braucht libstdc++
SQLAlchemy async benötigt greenlet, das gegen libstdc++ linkt.
**Fix**: `LD_LIBRARY_PATH` wird im flake.nix shellHook gesetzt:
```nix
shellHook = ''
  export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
'';
```

### Tests außerhalb von nix develop
Wenn Tests direkt (ohne `nix develop`) laufen sollen:
```bash
LD_LIBRARY_PATH=$(nix eval --raw nixpkgs#stdenv.cc.cc.lib)/lib:$LD_LIBRARY_PATH uv run pytest tests/ -v
```

### Flutter/Dart
- Nur via `nix develop` verfügbar
- `flutter create`, `flutter pub add`, `flutter test` etc. immer innerhalb der nix shell ausführen
