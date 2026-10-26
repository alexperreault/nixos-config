{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Started from hyprland.lua, not as a systemd service: graphical-session.target
  # is also reached by the GNOME session on rve.
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.gvfs.enable = true;

  home-manager.users.alexp =
    {
      config,
      pkgs,
      lib,
      osConfig,
      ...
    }:
    {
      home.packages = with pkgs; [
        bibata-cursors
        libnotify
        nautilus
        nwg-displays
        papirus-icon-theme
        playerctl
        wl-clipboard
      ];

      # Hyprland dotfiles symlink
      xdg.configFile."hypr".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/hypr";

      # Defaults only: changes made in the settings UI land in
      # ~/.local/state/noctalia/settings.toml and override these.
      programs.noctalia = {
        enable = true;
        settings = {
          bar.default = {
            background_opacity = 0.9;
            start = [
              "session"
              "workspaces"
            ];
            end = [
              "media"
              "tray"
              "notifications"
              "clipboard"
              "network"
              "bluetooth"
              "volume"
              "brightness"
              "battery"
              "control-center"
            ];
            layer = "overlay";
            reserve_space = false;
            show_on_workspace_switch = false;
            smart_auto_hide = true;
          };

          hot_corners = {
            enabled = true;
            top_left.action = "window_switcher";
            top_right = {
              action = "command";
              # Delay so the pointer settling in the corner doesn't wake the screen right away
              command = "sleep 1 && noctalia msg dpms-off";
            };
          };

          hooks.started = [ "noctalia msg wallpaper-random" ];

          idle = {
            behavior_order = [ "screen-off" ];
            behavior.screen-off = {
              action = "screen_off";
              enabled = true;
              timeout = 180.0;
            };
          };

          location.address = "Montreal, QC";

          lockscreen = {
            grace_period_seconds = 5;
            transition = [ "fade" ];
          };

          lockscreen_widgets.enabled = false;

          nightlight = {
            enabled = true;
            temperature_night = 4500;
          };

          shell = {
            clipboard_history_max_entries = 10;
            lang = "fr";
            polkit_agent = true;
            settings_show_advanced = false;
            animation.speed = 3.0;
            launcher = {
              categories = false;
              layout = "simple";
            };
            panel = {
              session_placement = "floating";
              session_position = "center";
              transparency_mode = "glass";
            };
          };

          theme = {
            builtin = "Noctalia";
            community_palette = "Oxocarbon";
            mode = "dark";
            source = "wallpaper";
            wallpaper_scheme = "m3-tonal-spot";
            templates.builtin_ids = [ "hyprland" ];
          };

          wallpaper = {
            directory = "${config.home.homeDirectory}/Pictures/wallpaper";
            default.path = "${config.home.homeDirectory}/Pictures/wallpaper/cherstey.jpg";
            transition_on_startup = true;
            automation = {
              enabled = true;
              order = "random";
            };
          };
        };
      };

      gtk = {
        enable = true;
        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
      };

      # With a display manager, the session is picked there; a login shell
      # inside the GNOME session must not exec into Hyprland.
      programs.fish.loginShellInit = lib.mkIf (!osConfig.services.displayManager.gdm.enable) ''
        if uwsm check may-start
          exec uwsm start hyprland.desktop
        end
      '';
    };
}
