{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    aliases = {
      ff = "merge --ff-only";
      fast-forward = "merge --ff-only";
      pushall = "!git remote | xargs -L1 git push --all";
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      graph = "log --decorate --oneline --graph";
      add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";
    };
    userName = "Alan Panayotov";
    userEmail = lib.concatStrings ["alan" "panayotov" "@" "gmail" ".com"];
    extraConfig = {
      core = {editor = "${pkgs.vim}/bin/vim";};
      # url."git@github.com:".insteadOf = "https://github.com/";
      commit = {
        gpgsign = true;
      };
      push = {
        default = "current";
        autoSetupRemote = true;
      };
    };
    lfs.enable = true;
    ignores = [".direnv" "result"];
  };
}
