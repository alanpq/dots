{inputs, ...}: {
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.nixosModules.stylix = {pkgs, ...}: {
    imports = [inputs.stylix.nixosModules.stylix];

    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal.yaml";
      polarity = "dark";

      cursor = {
        package = pkgs.volantes-cursors;
        name = "volantes_cursors";
        size = 24;
      };

      fonts = {
        serif = {
          package = pkgs.poppins;
          name = "Poppins";
        };
        sansSerif = {
          package = pkgs.poppins;
          name = "Poppins";
        };
        monospace = {
          package = pkgs.maple-mono.truetype;
          name = "Maple Mono";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
