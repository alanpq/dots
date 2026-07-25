{inputs, ...}: {
  # expansion of default system with basic system settings & cli-tools

  flake.modules.nixos.system-cli = {
    imports = with inputs.self.modules.nixos; [
      system-default

      tailscale

      ssh
      firmware
      cli-tools
    ];
  };

  flake.modules.hjem.system-cli = {
    imports = with inputs.self.modules.hjem; [
      system-default

      cli-tools

      # shell
    ];
  };
}
