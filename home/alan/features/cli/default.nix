{pkgs, ...}: {
  imports = [
    ./bash.nix
    ./bat.nix
    ./direnv.nix
    ./gh.nix
    ./git.nix
    ./gpg.nix
    ./nix-index.nix
    # ./pfetch.nix
    ./ranger.nix
    ./shellcolor.nix
    ./ssh.nix
    ./starship.nix
  ];
  home.shellAliases = {
    ip = "ip -color";

    ls = "exa";
    ll = "exa -l";
    la = "exa -la";
    tree = "exa -T";
  };
  home.packages = with pkgs; [
    comma # Install and run programs by sticking a , before them
    distrobox # Nice escape hatch, integrates docker images with my environment

    tmux # self explanatory

    bc # Calculator
    bottom # System viewer
    ncdu # TUI disk usage
    eza # Better ls
    ripgrep # Better grep
    fd # Better find
    httpie # Better curl
    diffsitter # Better diff
    jq # JSON pretty printer and manipulator
    # trekscii # Cute startrek cli printer
    timer # To help with my ADHD paralysis

    git-crypt

    nil # Nix LSP
    nixfmt # Nix formatter
    nixpkgs-fmt # also nix formatter
    nvd # Differ
    nix-output-monitor
    # nh # Nice wrapper for NixOS and HM

    ltex-ls # Spell checking LSP

    tly # Tally counter
  ];
}
