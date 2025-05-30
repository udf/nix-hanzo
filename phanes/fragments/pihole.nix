{ config, lib, pkgs, ... }:
let
  serverIP = "192.168.0.5";
  httpsPort = 16443;
in
{
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:2025.04.0";
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "${toString httpsPort}:${toString httpsPort}"
    ];
    volumes = [
      "/var/lib/pihole/:/etc/pihole/"
      "/var/lib/dnsmasq.d:/etc/dnsmasq.d/"
    ];
    environment = {
      ServerIP = serverIP;
      TZ = "Africa/Johannesburg";
      WEB_PORT = toString httpsPort;
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
    allowedTCPPorts = [ 53 httpsPort ];
    allowedUDPPorts = [ 53 ];
  };
}