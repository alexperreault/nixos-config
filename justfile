# Rebuild the NixOS system and switch
nix-rebuild:
    sudo nixos-rebuild switch --flake .

# Rebuild the NixOS system and test
nix-rebuild-test:
    sudo nixos-rebuild test --flake .

# Rebuild from the GitHub remote, bypassing the flake cache
nix-rebuild-remote:
    sudo nixos-rebuild switch --refresh --flake github:alexperreault/nixos-config#$(hostname)

# Kill and relaunch noctalia
shell-restart:
    pkill -u "$(whoami)" -x noctalia || true
    uwsm app -- noctalia &

# Format the flake with nixfmt
fmt:
    nix fmt

# Lint with statix
lint:
    statix check .
