{lib, ...}: let
  inherit (lib) types mkOption;
in
  with types; {
    flake.modules.hjem.desktop = {
      config,
      options,
      ...
    }: {
      options.desktop = {
        appLauncher = {
          package = mkOption {
            type = package;
          };
          openCmd = mkOption {
            type = str;
            default = "${lib.attrsets.getBin config.desktop.appLauncher.package}";
            description = "command to open the launcher";
          };
        };
      };

      config.warnings = (lib.optional (builtins.length options.desktop.appLauncher.package.files > 1)) ''
        desktop.appLauncher.package is set in multiple places (${builtins.concatStringsSep ", " options.desktop.appLauncher.package.files}); only one app launcher should be configured.
      '';
    };
  }

