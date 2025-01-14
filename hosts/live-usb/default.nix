{
  pkgs,
  inputs,
  outputs,
  config,
  modulesPath,
  ...
}: {
  imports =
    [
      "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
      "${modulesPath}/installer/cd-dvd/channel.nix"

      ../common/global/minimal.nix
    ]
    ++ (builtins.attrValues outputs.nixosModules);

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  home-manager.extraSpecialArgs = {inherit inputs outputs;};
  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  users.mutableUsers = false;
  users.users.nixos.packages = [pkgs.home-manager];

  home-manager.users.nixos = import ../../home/alan/${config.networking.hostName}.nix;

  hardware.enableRedistributableFirmware = true;

  networking = {
    hostName = "live-usb";
    useDHCP = true;
  };
}
