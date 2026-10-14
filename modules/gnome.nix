_:
{
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  home-manager.users.alexp =
    { lib, pkgs, ... }:
    let
      # Workspace i is bound to key "1".."9", then "0" for 10, like hyprland.lua.
      workspaceKey = i: toString (lib.mod i 10);
      workspaceBinds =
        prefix: mods:
        lib.listToAttrs (
          map (i: lib.nameValuePair "${prefix}-${toString i}" [ "${mods}${workspaceKey i}" ]) (lib.range 1 10)
        );
      vim = {
        left = "h";
        down = "j";
        up = "k";
        right = "l";
      };
      forgeBinds =
        action: mods:
        lib.mapAttrs' (dir: key: lib.nameValuePair "${action}-${dir}" [ "${mods}${key}" ]) vim;
    in
    {
      home.packages = [ pkgs.gnomeExtensions.forge ];

      dconf.settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [ pkgs.gnomeExtensions.forge.extensionUuid ];
        };

        "org/gnome/mutter".dynamic-workspaces = false;
        "org/gnome/desktop/wm/preferences".num-workspaces = 10;

        "org/gnome/desktop/wm/keybindings" =
          workspaceBinds "switch-to-workspace" "<Super>"
          // workspaceBinds "move-to-workspace" "<Super><Shift>"
          // {
            # Super+H belongs to Forge focus-left
            minimize = [ ];
          };

        # Default Super+N launches dock apps; free it for workspaces
        "org/gnome/shell/keybindings" = lib.listToAttrs (
          map (i: lib.nameValuePair "switch-to-application-${toString i}" [ ]) (lib.range 1 9)
        );

        "org/gnome/settings-daemon/plugins/media-keys" = {
          # Lock moves off Super+L (Forge focus-right)
          screensaver = [ "<Super>Escape" ];
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
          name = "Terminal";
          command = "foot";
          binding = "<Super>Return";
        };

        # Same as hyprland.lua: Super+hjkl focus, Super+Shift+hjkl swap
        "org/gnome/shell/extensions/forge/keybindings" =
          forgeBinds "window-focus" "<Super>"
          // forgeBinds "window-swap" "<Super><Shift>"
          // forgeBinds "window-move" "<Super><Control>"
          // {
            # Forge's default is Super+Return, which is the terminal here
            window-swap-last-active = [ ];
          };
      };
    };
}
