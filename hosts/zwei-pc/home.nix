{ config, pkgs, lib, ... }:
let user = "alan";
in {
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "23.05";


  imports = [
    ../../home.nix # common home config
  ];

}