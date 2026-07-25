{inputs, ...}: let
  genericPackages = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      comma

      git
      lazygit

      tmux
      # local.cowsay
    ];
  };
in {
  flake.modules.nixos.cli-tools = {
    imports = with inputs.self.modules.nixos; [
      genericPackages
      neovim
    ];
  };
  flake.modules.hjem.cli-tools = {
    imports = with inputs.self.modules.hjem; [alacritty];
  };
}
