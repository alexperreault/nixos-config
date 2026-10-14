{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core.nix
    ../../modules/hyprland.nix
    ../../modules/gnome.nix
    ../../modules/casting.nix
    ../../modules/home-manager.nix
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "rve";

  system.autoUpgrade = {
    enable = true;
    flake = "github:alexperreault/nixos-config#rve";
    flags = [ "--refresh" ];
    dates = "Sat 05:00";
    randomizedDelaySec = "30min";
    allowReboot = false;
  };

  services = {
    fwupd.enable = true;
    # ST-Link probes without root
    udev.packages = [ pkgs.stlink ];
  };

  # Serial / ST-Link virtual COM port
  users.users.alexp.extraGroups = [ "dialout" ];

  home-manager.users.alexp =
    { lib, pkgs, ... }:
    {
      home.packages = with pkgs; [
        stm32cubemx
      ];

      programs.vscode.enable = true;

      programs.git.settings.user.email = lib.mkForce "a.perreault@rve.ca";
    };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
