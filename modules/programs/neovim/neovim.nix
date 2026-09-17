{inputs, ...}: {
  flake.modules.nixos.neovim = {pkgs, ...}: {
    environment.systemPackages = [
      inputs.neovim.packages.${pkgs.stdenv.hostPlatform.system}.neovim
      pkgs.alejandra
    ];
    environment.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
