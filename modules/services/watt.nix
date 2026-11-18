{lib, ...}: {
  flake.modules.nixos.watt = {
    services = {
      tlp.enable = lib.mkForce false;
      thermald.enable = lib.mkForce false;
      watt = {
        enable = true;
      };
    };
  };
}
