{ config, pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.gvfs.enable = true;

  home-manager.users.alexp =
    { config, pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          bibata-cursors
          bluetui
          grim
          libnotify
          matugen
          nautilus
          papirus-icon-theme
          playerctl
          wiremix
          quickshell
          satty
          slurp
          wl-clipboard
        ];

        file.".config/matugen/config.toml".source = ../dotfiles/matugen/config.toml;
      };

      # Hyprland dotfiles symlink
      xdg.configFile."hypr".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/hypr";

      # Quickshell dotfiles symlink (edits are live: Quickshell's own file
      # watcher hot-reloads through the symlink, unlike Hyprland's).
      xdg.configFile."quickshell".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/quickshell";

      gtk = {
        enable = true;
        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
      };

      programs.fish.loginShellInit = ''
        if uwsm check may-start
          exec uwsm start hyprland.desktop
        end
      '';

      services = {
        hyprpaper.enable = true;
        hyprpolkitagent.enable = true;
        hyprsunset.enable = true;
        hypridle.enable = true;
      };
    };
}
