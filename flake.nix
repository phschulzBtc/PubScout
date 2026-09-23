{
  description = "PubScout - Find bars & pubs with activities";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.android_sdk.accept_license = true;
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Flutter & Dart
            flutter
            dart

            # Python
            python313
            uv
            ruff

            # Database
            sqlite

            # Tools
            pre-commit
            git
          ];

          shellHook = ''
            echo "PubScout dev environment loaded"
            echo "  Flutter: $(flutter --version 2>/dev/null | head -1 || echo 'available')"
            echo "  Python:  $(python3 --version)"
            echo "  uv:      $(uv --version)"
          '';
        };
      });
}
