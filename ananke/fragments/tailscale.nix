{ config, lib, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    port = 41641;
  };

  environment.systemPackages = [ pkgs.tailscale ];

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
