{ config, pkgs, inputs, ... }:

{
  home.username = "alexp";
  home.homeDirectory = "/home/alexp";

  home.packages = with pkgs; [
    bibata-cursors
    discord
    htop
    inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.fsel.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.naviterm.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    jq
    just
    lazygit
    libnotify
    playerctl
    seahorse
    swaynotificationcenter
    wiremix
    wl-clipboard
  ];

  home.file = {
    ".config/foot/foot.ini".source = dotfiles/foot/foot.ini;
    ".config/naviterm/config.ini".source = dotfiles/naviterm/config.ini;
    ".config/fsel/config.toml".source = dotfiles/fsel/config.toml;
  };

  # Hyprland dotfiles symlink
  xdg.configFile."hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/hypr";

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.fish = {
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

  programs.ssh = {
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

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Alexandre Perreault";
      email = "alexpqc@proton.me";
    };
    settings.alias = {
      st = "status -s";
      ci = "commit";
      sw = "switch";
      co = "checkout";
    };
  };

  programs.foot.enable = true;

  services.hyprpaper.enable = true;
  services.hyprpolkitagent.enable = true;
  services.hyprsunset.enable = true;
  services.hypridle.enable = true;

  # DO NOT TOUCH
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
