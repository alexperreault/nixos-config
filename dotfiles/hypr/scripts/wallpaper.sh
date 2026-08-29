#!/usr/bin/env bash
# Set the wallpaper, then regenerate the theme from it.
#
#   wallpaper.sh          -> pick a random image from WALLPAPER_DIR
#   wallpaper.sh <path>   -> use that image
#
# Run from hyprland.lua at session start, and available as `just wallpaper`.
set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/wallpaper}"
HERE="$(dirname "$(readlink -f "$0")")"

# `file` is not in this profile, and not every wallpaper here has a usable
# extension (laurentides is a WebP with no suffix), so sniff magic bytes.
is_image() {
    local magic
    magic=$(head -c 12 "$1" 2>/dev/null | od -A n -t x1 | tr -d ' \n')
    case "$magic" in
        ffd8ff*)             return 0 ;;  # JPEG
        89504e470d0a1a0a*)   return 0 ;;  # PNG
        52494646????????57454250) return 0 ;;  # RIFF....WEBP
        ff0a*|0000000c4a584c20*)  return 0 ;;  # JPEG XL
        424d*)               return 0 ;;  # BMP
        *)                   return 1 ;;
    esac
}

# hyprpaper is started by systemd alongside the session; at boot this script can
# easily win the race, so wait for its IPC to answer before issuing anything.
for _ in $(seq 1 40); do
    hyprctl hyprpaper listactive >/dev/null 2>&1 && break
    sleep 0.25
done

if [[ $# -ge 1 ]]; then
    wall="$1"
else
    mapfile -t candidates < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f | sort)
    images=()
    for f in "${candidates[@]}"; do
        is_image "$f" && images+=("$f")
    done
    if [[ ${#images[@]} -eq 0 ]]; then
        echo "wallpaper: no images found in $WALLPAPER_DIR" >&2
        exit 1
    fi
    wall="${images[RANDOM % ${#images[@]}]}"
fi

if [[ ! -f $wall ]]; then
    echo "wallpaper: not a file: $wall" >&2
    exit 1
fi

# Empty monitor field = fallback, i.e. every monitor without a specific target.
# This hyprpaper only supports `wallpaper` and `listactive`; there is no preload.
echo "wallpaper -> $wall"
hyprctl hyprpaper wallpaper ", $wall"

exec "$HERE/theme.sh"
