# base home file for all hosts
{ config, pkgs, lib, ... }:
let user = "alan";
in {
  programs.home-manager.enable = true;

  imports = [
    ./services/deadd-notification-center.nix
    ./configs/nvim
  ];

  home.packages = with pkgs; [
    tree

    htop
    file
    killall
    nixpkgs-fmt
    git-crypt

    xclip
    jq
    unzip
    usql

    keepassxc
  ];

  programs.firefox = {
    enable = true;
    # profiles."6pg7f79a".settings = {
    #   "widget.use-xdg-desktop-portal.file-picker" = 1;
    # };
  };
  programs.vscode.enable = true;
  programs.git = {
    enable = true;
    userEmail = lib.concatStrings [ "${user}" "panayotov" "@" "gmail" ".com" ];
    userName = "Alan Panayotov";
    aliases = {
      lg =
        "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      pushf = "push --force-with-lease";
      addall = "add --all";
      ff = "pull --ff-only";
    };
    extraConfig = {
      core = { editor = "${pkgs.vim}/bin/vim"; };
      url."git@github.com:".insteadOf = "https://github.com/";
      push = {
        default = "current";
        autoSetupRemote = true;
      };
    };
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      la = "ls -a";
      ll = "ls -l";
      lal = "ls -al";

      g = "git";
      gs = "git status";
      gp = "git push";
      gl = "git pull";
      ga = "git add";
      gc = "git commit";

      vim = "nvim";

      update = "sudo nixos-rebuild switch";
    };
    history = {
      path = "${config.xdg.dataHome}/zsh/history";
    };
    enableAutosuggestions = true;
    syntaxHighlighting = {
      enable = true;
    };
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
        { name = "extract"; tags = [ from:oh-my-zsh ]; }
        { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
      ];
    };
    initExtra = "
      source ~/.p10k.zsh
    ";
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true; # see note on other shells below
    enableZshIntegration = true;
    # nix-direnv.enable = true;
  };
  programs.bash.enable = true;

  programs.ssh = {
    enable = true;
    controlMaster = "auto"; # connection multiplexing
    matchBlocks = {
      "*github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_git";
      };
      "vm" = {
        hostname = "192.168.122.238";
        identityFile = "~/.ssh/id_vm";
      };
      "devbox-101" = {
        user = "admin";
        hostname = "192.168.122.238";
        port = 22101;
        identityFile = "~/.ssh/id_vm";
      };
      "ein" = {
        hostname = "gs.alanp.me";
      };
      "vps" = {
        hostname = builtins.concatStringsSep "." [ "65" "21" "108" "226" ]; # revolutionary anti-scraper technology
        user = "root";
      };
    };
  };
}
