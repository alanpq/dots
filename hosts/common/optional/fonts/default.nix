{
  pkgs,
  lib,
  config,
  ...
}: {
  nixpkgs.config.joypixels.acceptLicense = true;
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override {fonts = ["IosevkaTerm"];})
      iosevka
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      noto-fonts-emoji-blob-bin
      noto-fonts-extra
      noto-fonts-lgc-plus
      joypixels
      dejavu_fonts
      fira-code
      font-awesome_4
      font-awesome_6
      font-awesome_5
      twemoji-color-font
      twitter-color-emoji
      openmoji-black
      openmoji-color
      inconsolata
      _3270font
      comic-mono
      comic-relief
    ];
    fontDir.enable = true;
    fontconfig = {
      enable = true;
      hinting = {
        enable = true;
        autohint = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      allowBitmaps = true;
      useEmbeddedBitmaps = true;
      defaultFonts = {
        inherit (import ./fonts.nix) monospace sansSerif emoji serif;
      };
    };
  };
}
