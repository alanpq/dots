{ config, pkgs, lib, ... }: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  home.packages = with pkgs; [
    lazygit
    myNodePkgs."@vtsls/language-server"
  ];

  xdg.configFile."nvim" = {
    source = ./config;
    recursive = true;
  };
}
