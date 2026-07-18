{inputs, ...}: {
  flake.modules.nixos.chudpad = {
    imports = with inputs.self.modules.nixos; [
      system-laptop
      systemd-boot
      # bluetooth
    ];
  };
}
