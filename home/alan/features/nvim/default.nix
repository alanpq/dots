{ config, pkgs, lib, ... }: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  xdg.configFile."nvim/lua/custom" = {
    source = ./custom;
    recursive = true;
  };

  xdg.configFile."nvim" = {
    source = builtins.fetchGit {
      url = "https://github.com/NvChad/NvChad.git";
      rev = "9d37797e6f9856ef25cfa266cff43f764e828827";
      allRefs = true;
    };
    recursive = true;
  };
}
