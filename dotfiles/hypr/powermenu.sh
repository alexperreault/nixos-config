#!/usr/bin/env bash
# Simple system-control menu driven by `fsel --dmenu`.
# Launch inside a terminal, e.g.: foot --title=powermenu ~/.config/hypr/powermenu.sh

choice=$(printf '%s\n' \
  " Suspend" \
  " Reboot" \
  " Shutdown" \
  " Exit Hyprland" \
  | fsel --dmenu)

case "$choice" in
  *Suspend)  systemctl suspend  ;;
  *Reboot)   systemctl reboot   ;;
  *Shutdown) systemctl poweroff ;;
  *Exit*)    hyprctl dispatch exit ;;
esac
