{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs; [
      tree-sitter-grammars.tree-sitter-nix
      vimPlugins.rustaceanvim
      vimPlugins.markdown-preview-nvim
    ];
  };

  home.packages = with pkgs; [
    lazygit
    nil
    myNodePkgs."@vtsls/language-server"
    alejandra
  ];

  xdg.configFile."nvim" = {
    source = ./config;
    recursive = true;
  };
}
