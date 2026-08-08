{
  config,
  pkgs,
  inputs,
  ...
}:
let
  gitEmail = "alexpqc@proton.me";
  sshSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqVzkvGdw1ihqyZuGX3Njrf4OW2lGtFAu0xdnKkYb2T";
in
{
  imports = [
    inputs.lazyvim.homeManagerModules.default
    inputs.nixcord.homeModules.nixcord
  ];

  home = {
    username = "alexp";
    homeDirectory = "/home/alexp";

    packages = with pkgs; [
      bibata-cursors
      htop
      inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.fsel.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.naviterm.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      jq
      just
      lazygit
      libnotify
      pika-backup
      playerctl
      ripgrep
      seahorse
      swaynotificationcenter
      wiremix
      wl-clipboard
    ];

    file = {
      ".config/foot/foot.ini".source = dotfiles/foot/foot.ini;
      ".config/naviterm/config.ini".source = dotfiles/naviterm/config.ini;
      ".config/fsel/config.toml".source = dotfiles/fsel/config.toml;
      ".ssh/allowed_signers".text = "${gitEmail} ${sshSigningKey}\n";
    };
  };

  # Hyprland dotfiles symlink
  xdg.configFile."hypr".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/hypr";

  programs = {
    lazyvim = {
      enable = true;

      extras = {
        lang.nix = {
          enable = true;
          installDependencies = true;
        };
      };

      extraPackages = with pkgs; [
        nixd
        nixfmt
        statix
      ];
    };

    fish = {
      enable = true;
      shellAliases = {
        ll = "ls -al";
        cd = "z";
        gg = "lazygit";
      };
      interactiveShellInit = ''
        set -g fish_greeting ""
      '';
      loginShellInit = ''
        if uwsm check may-start
          exec uwsm start hyprland.desktop
        end
      '';
    };

    nixcord = {
      enable = true;
      discord = {
        silenceNoModClientWarning = true;
        krisp.enable = true;
      };
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "prod" = {
          HostName = "prod.alexpqc.com";
        };
        "pass" = {
          HostName = "192.168.9.3";
        };
        "media" = {
          HostName = "media.alexpqc.com";
        };
        "nas" = {
          HostName = "nas.alexpqc.com";
        };
        "pve" = {
          HostName = "192.168.8.9";
          User = "root";
        };
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      # Suppress direnv's own chatter (loading/using flake/export list);
      # the devShell's shellHook and direnv errors still print.
      silent = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "Alexandre Perreault";
          email = gitEmail;
          signingKey = "key::${sshSigningKey}";
        };
        gpg = {
          format = "ssh";
          ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        };
        commit.gpgsign = true;
        tag.gpgsign = true;
        alias = {
          st = "status -s";
          ci = "commit";
          sw = "switch";
          co = "checkout";
        };
      };
    };
    foot.enable = true;
  };

  services = {
    hyprpaper.enable = true;
    hyprpolkitagent.enable = true;
    hyprsunset.enable = true;
    hypridle.enable = true;
  };

  # DO NOT TOUCH
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
