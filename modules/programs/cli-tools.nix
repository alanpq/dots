{inputs, ...}: let
  genericPackages = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      comma

      git
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
}
