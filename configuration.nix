{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
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

  networking = {
    hostName = "north";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Toronto";

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = false;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    xserver = {
      enable = false;
      xkb = {
        layout = "ca";
        variant = "multix";
      };
    };

    printing.enable = true;

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    udev.extraRules = ''
      KERNEL=="event*", SUBSYSTEM=="input", ENV{ID_VENDOR_ID}=="3434", ENV{ID_INPUT_JOYSTICK}=="*?", ENV{ID_INPUT_JOYSTICK}=""
    '';

    # Keyring setup
    gnome = {
      gnome-keyring.enable = true;
      gcr-ssh-agent.enable = true;
    };

    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        X11Forwarding = false;
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "alexp" ];
        MaxAuthTries = 3;
        PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
      };
    };
  };

  i18n.defaultLocale = "en_CA.UTF-8";

  console.keyMap = "cf";

  hardware.graphics.enable = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  security = {
    rtkit.enable = true;

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

  users.users."alexp" = {
    isNormalUser = true;
    description = "Alex";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqVzkvGdw1ihqyZuGX3Njrf4OW2lGtFAu0xdnKkYb2T alexpqc@proton.me"
    ];
    shell = pkgs.fish;
  };

  programs = {
    # Hyprland :D
    hyprland = {
      enable = true;
      withUWSM = true;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    git.enable = true;

    fish.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      clang
      ghostty.terminfo
      wireguard-tools
      wget
    ];
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  fileSystems."/mnt/musique" = {
    device = "nas.alexpqc.com:/nas/media_nas/jellyfin/Musique";
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
