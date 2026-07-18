{
  flake.modules.nixos.chudpad = {
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/771a526d-e37c-490e-b199-0501dd520f6f";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/5CDB-4FCB";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/a4296477-a6fd-4c4b-817f-d7da97dcd9f7";}
    ];
  };
}
