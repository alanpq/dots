{
  flake.modules.nixos.sunshine = {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true; # needed for wayland
      openFirewall = true;
    };
    hardware.uinput.enable = true;
  };
}
