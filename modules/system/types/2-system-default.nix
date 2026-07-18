{inputs, ...}: {
  # import all essential nix-tools which are used in all modules of a specific class

  flake.modules.nixos.system-default = {
    imports = with inputs.self.modules.nixos;
      [
        system-minimal
        hjem
        # secrets
      ]
      ++ (with inputs.self.modules.generic; [
        # systemConstants
        pkgs-by-name
      ]);
  };

  flake.modules.hjem.system-default = {
    imports = with inputs.self.modules.hjem; [
      system-minimal
      # secrets
    ];
    # ++ [inputs.self.modules.generic.systemConstants];
  };
}
