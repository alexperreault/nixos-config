#!/usr/bin/env bash
# Toggle hyprsunset's filter by hand. The next profile switch in
# hyprsunset.conf takes over again, so this only lasts until 7:30 / 19:00.
set -euo pipefail

if [[ $(hyprctl hyprsunset identity get) == "true" ]]; then
    # Same values as the 19:00 profile in hyprsunset.conf
    hyprctl hyprsunset temperature 5000 >/dev/null
    hyprctl hyprsunset gamma 80 >/dev/null
    notify-send "Night light" "On"
else
    hyprctl hyprsunset identity true >/dev/null
    notify-send "Night light" "Off"
fi
