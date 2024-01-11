{ pkgs, inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.lenovo-thinkpad-t14
    ./hardware-configuration.nix
    ../common/global

    ../common/optional/ephemeral-btrfs.nix

    ../common/optional/greetd.nix

    ../common/users/alan
  ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "zwei-pc";
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
