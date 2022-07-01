{ config, lib, pkgs, ... }:
{
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    port = 80;
  };
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}