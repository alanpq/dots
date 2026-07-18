{
  flake.modules.nixos.chudpad = {
    boot = {
      supportedFilesystems = ["ntfs" "vfat" "ext4" "lvm" "btrfs"];
      initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/2acacb9f-fe23-4c80-bf96-695fe89adbf3";

      loader.efi.canTouchEfiVariables = true;
    };

    fileSystems."/" = {
      device = "/dev/pool/root";
      fsType = "ext4";
    };
    swapDevices = [{device = "/dev/pool/swap";}];

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/5CDB-4FCB";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };

    # swapDevices = [
    #   {device = "/dev/disk/by-uuid/a4296477-a6fd-4c4b-817f-d7da97dcd9f7";}
    # ];
  };
}
