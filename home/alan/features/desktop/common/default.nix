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
    ./pcmanfm.nix
    ./thunar.nix
    ./playerctl.nix
    ./qt.nix
  ];
  xdg.portal.enable = true;
}
