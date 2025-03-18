{
  outputs,
  lib,
  ...
}: let
  hostnames = builtins.attrNames outputs.nixosConfigurations;
in {
  programs.ssh = {
    enable = true;
    controlMaster = "auto"; # connection multiplexing
    matchBlocks = {
      "*github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_git";
      };
      "vm" = {
        hostname = "192.168.122.35";
        identityFile = "~/.ssh/id_vm";
      };
      "devbox-101" = {
        hostname = "127.0.0.1";
        port = 22101;
        identityFile = "~/.ssh/id_vm";
        proxyJump = "vm";
        user = "admin";
      };
      "ein" = {
        hostname = "gs.alanp.me";
        identityFile = "~/.ssh/id_ein";
      };
      "pi" = {
        hostname = "raspberrypi";
        user = "pi";
        port = 22;
        proxyJump = "ein";
        identityFile = "~/.ssh/id_pi";
      };
      "vps" = {
        hostname = builtins.concatStringsSep "." ["65" "21" "108" "226"]; # revolutionary anti-scraper technology
        user = "root";
        identityFile = "~/.ssh/id_vps";
      };
    };
  };

  # home.persistence = {
  #   "/persist/home/alan".directories = [ ".ssh" ];
  # };
}
