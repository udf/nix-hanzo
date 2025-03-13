{ config, lib, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    port = 41641;
    useRoutingFeatures = "both";
  };

  environment.systemPackages = [ pkgs.tailscale ];

  custom.ipset-block.exceptPorts = [ config.services.tailscale.port ];

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
