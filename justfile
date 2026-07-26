# Update the flake
update-flake:
    nix flake update

# Rebuild the NixOS system and switch
nix-rebuild:
    sudo nixos-rebuild switch --flake .

# Rebuild the NixOS system and test
nix-rebuild-test:
    sudo nixos-rebuild test --flake .

# nixos-rebuild switch restarts NetworkManager; wait for the network to come back
wait-net:
    #!/usr/bin/env bash
    set -euo pipefail
    nm-online -s -q --timeout=120 || true
    for i in $(seq 1 60); do
        getent hosts cache.nixos.org >/dev/null 2>&1 && exit 0
        sleep 2
    done
    echo "network did not come back within 2 minutes" >&2
    exit 1

# Rebuild Home manager and switch
home-switch:
    home-manager switch --flake .
    fsel --refresh-cache

# Stage changes, grab the active generation number, commit, and push
commit:
    #!/usr/bin/env bash
    set -euo pipefail
    GEN_NIXOS=$(nixos-rebuild list-generations | awk '/True/ {print $1}')
    GEN_HOME=$(home-manager generations | awk '/current/ {print $5}')
    git add .
    git commit -m "n${GEN_NIXOS} : h${GEN_HOME}"
    git push

# Update flake, rebuild and switch, then commit the generation
update: update-flake nix-rebuild wait-net home-switch commit
