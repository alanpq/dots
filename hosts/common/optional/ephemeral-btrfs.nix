# This file contains an ephemeral btrfs root configuration
# NOTE: this module assumes you have your filesystems sorted, so be careful :)
# TODO: perhaps partition using disko in the future
{
  lib,
  config,
  ...
}: let
  hostname = config.networking.hostName;
  hostnameEscape = builtins.replaceStrings ["-"] ["\\x2d"] hostname;
  wipeScript = ''
    mkdir /tmp -p
    MNTPOINT=$(mktemp -d)
    (
      mount -t btrfs -o subvol=/ /dev/mapper/enc "$MNTPOINT"
      trap 'umount "$MNTPOINT"' EXIT

      echo "Cleaning root subvolume"
      btrfs subvolume list -o "$MNTPOINT/root" | cut -f9 -d ' ' |
      while read -r subvolume; do
        echo "deleting /$subvolume subvolume..."
        btrfs subvolume delete "$MNTPOINT/$subvolume"
      done && btrfs subvolume delete "$MNTPOINT/root"

      echo "Restoring blank subvolume"
      btrfs subvolume snapshot "$MNTPOINT/root-blank" "$MNTPOINT/root"
    )
  '';
  phase1Systemd = config.boot.initrd.systemd.enable;
in {
  boot.initrd = {
    supportedFilesystems = ["btrfs"];
    postDeviceCommands = lib.mkIf (!phase1Systemd) (lib.mkBefore wipeScript);
    systemd.services.restore-root = lib.mkIf phase1Systemd {
      description = "Rollback btrfs rootfs";
      wantedBy = ["initrd.target"];
      requires = [
        # "dev-disk-by\\x2dlabel-${hostnameEscape}.device"
      ];
      after = [
        # "dev-disk-by\\x2dlabel-${hostnameEscape}.device"
        "systemd-cryptsetup@${hostname}.service"
      ];
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = wipeScript;
    };
  };

  # fileSystems = {
  #   "/" = {
  #     device = "/dev/disk/by-label/${hostname}";
  #     fsType = "btrfs";
  #     options = [ "subvol=root" "compress=zstd" ];
  #   };

  #   "/nix" = {
  #     device = "/dev/disk/by-label/${hostname}";
  #     fsType = "btrfs";
  #     options = [ "subvol=nix" "noatime" "compress=zstd" ];
  #   };

  #   "/persist" = {
  #     device = "/dev/disk/by-label/${hostname}";
  #     fsType = "btrfs";
  #     options = [ "subvol=persist" "compress=zstd" ];
  #     neededForBoot = true;
  #   };

  #   "/swap" = {
  #     device = "/dev/disk/by-label/${hostname}";
  #     fsType = "btrfs";
  #     options = [ "subvol=swap" "noatime" ];
  #   };
  # };
}
