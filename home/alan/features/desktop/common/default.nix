{
  imports = [
    ./deluge.nix
    ./discord.nix
    ./dragon.nix
    ./firefox.nix
    ./font.nix
    ./gtk.nix
    ./kdeconnect.nix
    ./pavucontrol.nix
    ./playerctl.nix
    ./qt.nix
  ];
  xdg.portal.enable = true;
}