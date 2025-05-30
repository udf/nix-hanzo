{ config, lib, pkgs, ... }:
{
  services.pihole-container = {
    enable = true;
    serverIP = "192.168.0.3";
    httpsPort = 16443;
    openFirewall = true;
  };

  users.users.sam.extraGroups = [ "podman" ];
}