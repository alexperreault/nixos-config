#!/usr/bin/env bash
# Regenerate the matugen palette from whatever wallpaper is currently displayed.
#
# The live wallpaper is runtime state (wallpaper.sh picks a random one each
# session), so hyprpaper's IPC is the source of truth, not hyprpaper.conf.
# hyprpaper.conf is only the fallback for when hyprpaper is not up yet.
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/matugen"
CONF="$HOME/.config/hypr/hyprpaper.conf"

current_wallpaper() {
    # "DP-1: /path/to/image" -> "/path/to/image", first monitor wins
    if wp=$(hyprctl hyprpaper listactive 2>/dev/null) && [[ -n $wp ]]; then
        sed -n '1s/^[^:]*:[[:space:]]*//p' <<<"$wp"
        return
    fi
    awk -F'=[[:space:]]*' '/^[[:space:]]*path[[:space:]]*=/ {print $2; exit}' "$CONF"
}

wall=$(current_wallpaper)
wall="${wall/#\~/$HOME}"

if [[ -z $wall || ! -f $wall ]]; then
    echo "theme: no usable wallpaper (got '${wall:-<empty>}')" >&2
    exit 1
fi

mkdir -p "$STATE_DIR"
echo "matugen <- $wall"
matugen image "$wall"

# Hyprland re-reads colors.lua on reload.
hyprctl reload >/dev/null 2>&1 || true
