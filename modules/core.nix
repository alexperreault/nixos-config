{
  config,
  pkgs,
  ...
}:
{
  networking.networkmanager.enable = true;

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

    # Keyring setup
    gnome = {
      gnome-keyring.enable = true;
      gcr-ssh-agent.enable = true;
    };

    openssh = {
      enable = true;
      openFirewall = false;
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

    tailscale = {
      enable = true;
      openFirewall = true;
    };
  };

  i18n.defaultLocale = "en_CA.UTF-8";

  console.keyMap = "cf";

  hardware.graphics.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

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
      options = "--delete-older-than 14d";
    };
  };

  security.rtkit.enable = true;

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

    fish.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      ghostty.terminfo
      wireguard-tools
    ];
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
