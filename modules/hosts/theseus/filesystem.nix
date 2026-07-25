{
  flake.modules.nixos.theseus = {
    boot = {
      supportedFilesystems = ["ntfs" "vfat" "ext4" "lvm" "btrfs"];
      initrd.luks.devices."crypted".device = "/dev/disk/by-uuid/c85a4f69-6fb8-4107-af03-e87ccf1686a2";

      loader.efi.canTouchEfiVariables = true;
      kernelParams = [
        "nvidia_drm.fbdev=1"
      ];
    };

    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-uuid/3B99-A666";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };

      "/" = {
        device = "/dev/disk/by-uuid/c271b1a1-a62e-4b3d-ac2b-03c090e43259";
        fsType = "btrfs";
        options = ["subvol=root"];
      };

      "/home" = {
        device = "/dev/disk/by-uuid/c271b1a1-a62e-4b3d-ac2b-03c090e43259";
        fsType = "btrfs";
        options = ["subvol=home" "compress=zstd" "noatime"];
      };

      "/nix" = {
        device = "/dev/disk/by-uuid/c271b1a1-a62e-4b3d-ac2b-03c090e43259";
        fsType = "btrfs";
        options = ["subvol=nix" "compress=zstd" "noatime"];
      };

      "/persist" = {
        device = "/dev/disk/by-uuid/c271b1a1-a62e-4b3d-ac2b-03c090e43259";
        fsType = "btrfs";
        options = ["subvol=persist" "compress=zstd" "noatime"];
        neededForBoot = true;
      };

      "/var/log" = {
        device = "/dev/disk/by-uuid/c271b1a1-a62e-4b3d-ac2b-03c090e43259";
        fsType = "btrfs";
        options = ["subvol=cache/logs" "compress=zstd" "noatime"];
        neededForBoot = true;
      };
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/6990eefc-ac66-40e9-b1a6-19b411da6a5a";}
    ];

    # swapDevices = [
    #   {device = "/dev/disk/by-uuid/a4296477-a6fd-4c4b-817f-d7da97dcd9f7";}
    # ];
  };
}
