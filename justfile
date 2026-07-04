# Update the flake
update-flake:
    nix flake update

# Rebuild the NixOS system and switch
nix-rebuild:
    sudo nixos-rebuild switch --flake .

# Rebuild the NixOS system and test
nix-rebuild-test:
    sudo nixos-rebuild test --flake .

# Rebuild Home manager and switch
home-switch:
    home-manager switch --flake .

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
update: update-flake nix-rebuild home-switch commit
