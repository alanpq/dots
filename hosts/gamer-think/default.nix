{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-intel
    inputs.hardware.nixosModules.lenovo-thinkpad-t14
    ./hardware-configuration.nix
    ../common/global

    # ../common/optional/greetd.nix
    ../common/optional/tui-greetd.nix

    ../common/optional/docker.nix
    ../common/optional/wireless.nix
    ../common/optional/lightd.nix

    ../common/optional/pipewire
    ../common/optional/pipewire/bluetooth.nix

    ../common/optional/gamemode.nix

    ../common/users/alan
  ];

  nix.settings.trusted-users = ["alan"];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["ntfs" "vfat" "ext4" "lvm" "btrfs"];
  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/2acacb9f-fe23-4c80-bf96-695fe89adbf3";

  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  services.openssh.settings.KbdInteractiveAuthentication = lib.mkForce true;

  fileSystems."/" = pkgs.lib.mkForce {
    device = "/dev/pool/root";
    fsType = "ext4";
  };
  swapDevices = [{device = "/dev/pool/swap";}];

  networking = {
    hostName = "gamer-think";
    useDHCP = true;
    dhcpcd.IPv6rs = false;
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

  system.stateVersion = "24.05";
}
