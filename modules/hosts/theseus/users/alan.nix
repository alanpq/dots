{
  inputs,
  self,
  ...
}: {
  flake.modules.nixos.theseus = {pkgs, ...}: {
    imports = with inputs.self.modules.nixos; [
      alan

      obs
    ];
    hjem.users.alan = {
      imports = with inputs.self.modules.hjem; [
        system-desktop

        discord
        easyeffects
        spotifyd
        obs

        ableton
      ];

      packages = with pkgs; [
        (chromium.override {
          commandLineArgs = "--ignore-gpu-blocklist --enable-features=VaapiVideoDecoder,VaapiVideoDecodeLinuxGL --ozone-platform=x11";
        })
        vscode

        spotify
        spotifyd

        pavucontrol
        easyeffects

        protontricks
        mangohud
        prismlauncher
        lutris

        parsec-bin
      ];
    };
  };
}
