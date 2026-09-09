{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core.nix
    ../../modules/gaming.nix
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

    # Blank the console (TTY) after 60s idle, like `setterm --blank` + consoleblank=60
    kernelParams = [ "consoleblank=60" ];
  };

  networking.hostName = "north";

  system.autoUpgrade = {
    enable = true;
    flake = "github:alexperreault/nixos-config#north";
    flags = [ "--refresh" ];
    dates = "05:00";
    randomizedDelaySec = "30min";
    allowReboot = false;
  };

  security = {
    # Setup fido2 (manual steps required to register the key)
    pam.services = {
      login = {
        u2fAuth = false;
        enableGnomeKeyring = true;
      };
      sudo.u2fAuth = true;
    };
    pam.u2f.settings.cue = true;
  };

  fileSystems."/mnt/musique" = {
    device = "nas:/nas/media_nas/jellyfin/Musique";
    fsType = "nfs";
    options = [
      "ro"
      "x-systemd.automount"
      "noauto"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
