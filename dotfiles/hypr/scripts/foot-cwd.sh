#!/usr/bin/env bash
pid=$(hyprctl activewindow -j | jq -r '.pid')
shell_pid=$(pgrep -P "$pid" | head -1)
cwd=$(readlink -f "/proc/${shell_pid:-$pid}/cwd" 2>/dev/null) || cwd="$HOME"
foot --working-directory "$cwd"
