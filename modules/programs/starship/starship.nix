{lib, ...}: {
  flake.modules.hjem.starship = {
    rum.programs = {
      starship = {
        enable = true;
        integrations = {
          zsh.enable = true;
        };

        settings = lib.foldl' lib.recursiveUpdate {} [
          (lib.importTOML ./mono.toml)
          {
            # add_newline = false;
          }
        ];
      };
    };
  };
}
