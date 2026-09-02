{
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    quickshell = inputs'.quickshell.packages.default;
    # qmlls resolves imports only from these paths; an empty QML_IMPORT_PATH is
    # why `import Quickshell`/`import QtQuick` fail when editing the source in-repo.
    qmllsImportPaths = pkgs.lib.concatStringsSep ":" [
      "${quickshell}/lib/qt-6/qml"
      "${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml"
      "${pkgs.kdePackages.qtwayland}/lib/qt-6/qml"
    ];

    # Run quickshell straight from the in-repo source so edits hot-reload,
    # replacing the managed service for the duration of the session.
    qs-dev = pkgs.writeShellApplication {
      name = "qs-dev";
      runtimeInputs = [quickshell pkgs.git pkgs.systemd pkgs.coreutils];
      text = ''
        repo=$(git rev-parse --show-toplevel)
        config="$repo/modules/desktop/quickshell/config"
        theme="''${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/config/Theme.qml"

        if [ ! -e "$config/shell.qml" ]; then
          echo "qs-dev: no quickshell source at $config" >&2
          exit 1
        fi
        # Theme.qml is generated from stylix and lives only in the installed
        # config; symlink it in so the source folder is a complete config.
        if [ ! -e "$theme" ]; then
          echo "qs-dev: generated $theme is missing." >&2
          echo "qs-dev: rebuild/switch once so the quickshell service installs it." >&2
          exit 1
        fi
        ln -sf "$theme" "$config/Theme.qml"

        # Hand the managed service back whenever the dev instance exits.
        trap 'echo "qs-dev: restarting managed service"; systemctl --user start quickshell || true' EXIT

        echo "qs-dev: stopping managed quickshell service"
        systemctl --user stop quickshell || true

        echo "qs-dev: running from $config (edits auto-reload, Ctrl-C to quit)"
        quickshell -p "$config" -v || true
      '';
    };
  in {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        nix
        nixpkgs-fmt
        alejandra

        stylua

        git
        git-crypt

        sops
        ssh-to-age
        gnupg
        age

        nh

        bun
        typescript
        typescript-language-server

        kdePackages.qtdeclarative

        qs-dev
      ];

      # Regenerate the gitignored qmlls config for the quickshell source. Store
      # paths change on every quickshell/Qt bump, so this is derived, not committed.
      shellHook = ''
        ini="$PWD/modules/desktop/quickshell/.qmlls.ini"
        if [ -d "$(dirname "$ini")" ]; then
          printf '[General]\nno-cmake-calls=true\nimportPaths=%s\n' \
            "${qmllsImportPaths}" > "$ini"
        fi
      '';
    };
  };
}
