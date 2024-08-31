{ pkgs, inputs, ...}: {
  imports = [
    inputs.hardware.nixosModules.lenovo-thinkpad-t14
    ./hardware-configuration.nix
    ../common/global

    ../common/optional/greetd.nix
    ../common/optional/docker.nix
    ../common/optional/wireless.nix
    ../common/optional/lightd.nix
    ../common/optional/pipewire.nix
    ../common/optional/gamemode.nix
    
    ../common/users/alan
  ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "gamer-think";
    useDHCP = true;
  };

  programs = {
    adb.enable = true;
    dconf.enable = true;
    kdeconnect.enable = true;
  };


  hardware = {
    opengl.enable = true;
    opentabletdriver.enable = true;
  };

  system.stateVersion = "22.11";
}
