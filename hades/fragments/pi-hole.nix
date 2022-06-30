{ config, lib, pkgs, ... }:
let
  serverIP = "192.168.1.2";
in
{
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:2022.05";
    ports = [
      "${serverIP}:53:53/tcp"
      "${serverIP}:53:53/udp"
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
      "--dns=127.0.0.1"
      "--dns=1.1.1.1"
      "--no-healthcheck"
    ];
  };

  users.users.sam.extraGroups = [ "podman" ];
}
