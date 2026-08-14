{inputs, ...}: let
  genericPackages = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      comma

      git
      lazygit

      tmux
      eza
      bat
      # local.cowsay
    ];
  };
in {
  flake.modules.nixos.cli-tools = {
    imports = with inputs.self.modules.nixos; [
      genericPackages
      neovim
    ];

    environment.shellAliases = {
      cat = "bat --paging never";
      ip = "ip -color";
      l = "exa -lah";
      la = "exa -la";
      ls = "exa";
      tree = "exa -T";
    };
  };
  flake.modules.hjem.cli-tools = {
    imports = with inputs.self.modules.hjem; [
      zsh
      alacritty
      starship
    ];

    rum.programs = {
      direnv = {
        enable = true;
        integrations = {
          zsh.enable = true;
        };
      };
    };
  };
}
