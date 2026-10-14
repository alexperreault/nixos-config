# PLACEHOLDER so the flake evaluates before rve is installed.
# On the laptop, replace this whole file with:
#   nixos-generate-config --show-hardware-config > devices/rve/hardware-configuration.nix
{ lib, ... }:
{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
