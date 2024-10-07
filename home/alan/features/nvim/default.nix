{ config, pkgs, lib, ... }: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs; [
      tree-sitter-grammars.tree-sitter-nix
    ];
  };

  home.packages = with pkgs; [
    lazygit
    nil
    myNodePkgs."@vtsls/language-server"
  ];

  xdg.configFile."nvim" = {
    source = ./config;
    recursive = true;
  };
}
