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
  home = {
    username = "alexp";
    homeDirectory = "/home/alexp";

    packages = with pkgs; [
      brave-origin
      htop
      inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.naviterm.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.nvim-conf.packages.${pkgs.stdenv.hostPlatform.system}.nvim
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      just
      lazygit
      pika-backup
      ripgrep
      seahorse
      wget
    ];

    file = {
      ".config/foot/foot.ini".source = ../dotfiles/foot/foot.ini;
      ".config/naviterm/config.ini".source = ../dotfiles/naviterm/config.ini;
      ".ssh/allowed_signers".text = "${gitEmail} ${sshSigningKey}\n";
    };
  };

  programs = {
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
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
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

  # DO NOT TOUCH
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
