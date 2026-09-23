# NixOS Notes

## Dev Environment
- Alle Tools via `nix develop` (flake.nix): Flutter, Dart, Python, uv, ruff, jq, pre-commit
- `.envrc` mit `use flake` für direnv-Integration

## Bekannte Probleme

### ruff aus uv funktioniert nicht
Dynamisch gelinkte Binaries aus pip/uv laufen nicht auf NixOS.
**Workaround**: `nix-shell -p ruff --run "ruff check ..."`

### Flutter/Dart
- Nur via `nix develop` verfügbar
- `flutter create`, `flutter pub add`, `flutter test` etc. immer innerhalb der nix shell ausführen
