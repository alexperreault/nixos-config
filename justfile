# Rebuild the NixOS system and switch
nix-rebuild:
    sudo nixos-rebuild switch --flake .

# Rebuild the NixOS system and test
nix-rebuild-test:
    sudo nixos-rebuild test --flake .

# Kill and relaunch quickshell (escape hatch when hot-reload wedges)
shell-restart:
    pkill -u "$(whoami)" -x quickshell || true
    uwsm app -- quickshell &

# Format the flake with nixfmt
fmt:
    nix fmt

# Lint with statix
lint:
    statix check .

# Pick a random wallpaper from ~/Pictures/wallpaper and retheme from it
wallpaper *ARGS:
    dotfiles/hypr/scripts/wallpaper.sh {{ARGS}}

# Regenerate the matugen palette from the wallpaper currently displayed
theme:
    dotfiles/hypr/scripts/theme.sh
