# base home file for all hosts
{ config, pkgs, lib, ... }:
let user = "alan";
in {
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    tree
    vim
  ];

  programs.firefox.enable = true;
  programs.vscode.enable = true;
  programs.git = {
    enable = true;
    userEmail = lib.concatStrings [ "${user}""panayotov""@""gmail"".com"];
    userName = "Alan Panayotov";
    aliases = {
      lg =
        "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      pushf = "push --force-with-lease";
      addall = "add --all";
      ff = "pull --ff-only";
    };
    extraConfig = {
      core = { editor = "${pkgs.vim}/bin/vim"; };
      url."git@github.com:".insteadOf = "https://github.com/";
      push = {
        default = "current";
        autoSetupRemote = true;
      };
    };
  };
}