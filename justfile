# Update the flake
update-flake:
    nix flake update

# Rebuild the NixOS system and switch
rebuild:
    sudo nixos-rebuild switch --flake .

# Rebuild the NixOS system and test
rebuild-test:
    sudo nixos-rebuild test --flake .

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
update: update-flake rebuild commit
