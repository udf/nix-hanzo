{ config, lib, pkgs, ... }:
let
  serverIP = "192.168.0.3";
in
{
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:2024.01.0";
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "80:80"
      "443:443"
    ];
    volumes = [
      "/var/lib/pihole/:/etc/pihole/"
      "/var/lib/dnsmasq.d:/etc/dnsmasq.d/"
    ];
    environment = {
      ServerIP = serverIP;
      TZ = "Africa/Johannesburg";
    };
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--dns=1.1.1.1"
      "--no-healthcheck"
      "--hostname=${config.networking.hostName}"
    ];
  };

  users.users.sam.extraGroups = [ "podman" ];

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}