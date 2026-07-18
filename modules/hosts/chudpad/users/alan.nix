{
  inputs,
  self,
  ...
}: {
  flake.modules.nixos.chudpad = {config, ...}: {
    imports = with inputs.self.modules.nixos; [
      alan
    ];
  };
}
