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
    git add .
    @GEN=$(nixos-rebuild list-generations | awk '/True/ {print $1}'); \
    git commit -m "${GEN}"
    git push

# Update flake, rebuild and switch, then commit the generation
update: update-flake rebuild commit
