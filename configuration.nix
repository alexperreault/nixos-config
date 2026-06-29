# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "north"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "ca";
    variant = "multix";
  };

  # Configure console keymap
  console.keyMap = "cf";

  # Enable graphics accel
  hardware.graphics.enable = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Auto updates
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";

  # Auto garbage collection
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 14d";
  nix.settings.auto-optimise-store = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."alexp" = {
    isNormalUser = true;
    description = "Alex";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqVzkvGdw1ihqyZuGX3Njrf4OW2lGtFAu0xdnKkYb2T alexpqc@proton.me" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  programs.hyprland.enable = true;

  # Keyring setup
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  services.gnome.gcr-ssh-agent.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bibata-cursors
    clang
    claude-code
    discord
    foot
    fzf
    git
    htop
    hyprlauncher
    hyprpaper
    hyprpolkitagent
    inputs.naviterm.packages.${pkgs.system}.default
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    kitty
    lazygit
    libnotify
    neovim
    playerctl
    seahorse
    swaynotificationcenter
    vim
    vimPlugins.LazyVim
    wget
  ];


  # ENV vars
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "alexp" ];
      MaxAuthTries = 3;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
