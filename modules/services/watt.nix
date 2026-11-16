{lib, ...}: {
  flake.modules.nixos.watt = {
    services.tlp.enable = lib.mkForce false;
    services.watt = {
      enable = true;
    };
  };
}
