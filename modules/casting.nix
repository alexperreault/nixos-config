{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gnome-network-displays
  ];

  # Chromecast / MICE discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  networking.firewall = {
    # RTSP (Miracast) and MICE
    allowedTCPPorts = [
      7236
      7250
    ];
    allowedUDPPorts = [ 7236 ];
    # Wi-Fi Direct link: NetworkManager serves DHCP to the sink on this interface
    trustedInterfaces = [ "p2p-wl+" ];
  };
}
