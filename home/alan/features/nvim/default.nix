{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  newNeoVim = inputs.neovim.packages.${pkgs.stdenv.system}.neovim;
in {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = false;
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
    (pkgs.writeShellScriptBin "vim" "exec -a $0 ${newNeoVim}/bin/nvim $@")
  ];

  xdg.configFile."nvim" = {
    source = ./config;
    recursive = true;
  };
}
