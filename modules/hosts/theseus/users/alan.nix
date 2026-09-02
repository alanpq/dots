{
  inputs,
  self,
  ...
}: {
  flake.modules.nixos.theseus = {
    config,
    pkgs,
    ...
  }: {
    imports = with inputs.self.modules.nixos; [
      alan
    ];
    hjem.users.alan = {
      imports = with inputs.self.modules.hjem; [
        system-desktop
        discord
        easyeffects
        spotifyd
      ];

      packages = [
        pkgs.vscode
        pkgs.prismlauncher
        pkgs.protontricks
        pkgs.spotify
        pkgs.spotifyd
        pkgs.mangohud
        pkgs.easyeffects
        pkgs.lutris
        pkgs.obs-studio
      ];
    };
  };
}
