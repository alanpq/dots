{
  inputs,
  config,
  lib,
  ...
}: {
  programs.matugen = {
    enable = false;
    variant = "dark";
    # jsonFormat = "hex";

    templates = {
      kitty = {
        input_path = ./templates/kitty-colors.conf;
        output_path = "~/.config/kitty/colors.conf";
      };

      gtk = {
        input_path = ./templates/gtk-colors.css;
        output_path = "~/.config/gtk-4.0/gtk.css";
      };

      hypr = {
        input_path = ./templates/hyprland-colors.conf;
        output_path = "~/.config/hypr/colors.conf";
      };

      pywalfox = {
        input_path = ./templates/pywalfox-colors.json;
        output_path = "~/.cache/wal/colors.json";
        # post_hook = "pywalfox update";
      };
    };
  };
  # home.file.".config/gtk-4.0/gtk.css".source = lib.mkIf config.programs.matugen.enable "${config.programs.matugen.theme.files}/.config/gtk-4.0/gtk.css";
  # home.file.".cache/wal/colors.json".source = lib.mkIf config.programs.matugen.enable "${config.programs.matugen.theme.files}/.cache/wal/colors.json";
}
