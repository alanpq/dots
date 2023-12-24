{ outputs, lib, ... }:
let
  hostnames = builtins.attrNames outputs.nixosConfigurations;
in
{
  programs.ssh = {
    enable = true;
    controlMaster = "auto"; # connection multiplexing
    matchBlocks = {
      "*github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_git";
      };
      "vm" = {
        hostname = "192.168.122.238";
        identityFile = "~/.ssh/id_vm";
      };
      "ein" = {
        hostname = "gs.alanp.me";
        identityFile = "~/.ssh/id_ein";
      };
      "vps" = {
        hostname = builtins.concatStringsSep "." [ "65" "21" "108" "226" ]; # revolutionary anti-scraper technology
        user = "root";
        identityFile = "~/.ssh/id_vps";
      };
    };
  };

  # home.persistence = {
  #   "/persist/home/alan".directories = [ ".ssh" ];
  # };
}
