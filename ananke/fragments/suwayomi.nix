{ config, lib, pkgs, ... }:
{
  virtualisation.oci-containers.containers.suwayomi = {
    image = "ghcr.io/suwayomi/tachidesk:v1.0.0-r1498";
    ports = [
      "4567:4567"
    ];
    volumes = [
      "data:/home/suwayomi/.local/share/Tachidesk"
    ];
    environment = {
      TZ = "Africa/Johannesburg";
      BASIC_AUTH_ENABLED = "true";
      BASIC_AUTH_USERNAME = "sam";
      BASIC_AUTH_PASSWORD = "hentai";
      EXTENSION_REPOS = ''[ "https://github.com/keiyoushi/extensions/tree/repo" ]'';
    };
    extraOptions = [
      "--hostname=${config.networking.hostName}"
      "--memory=512m"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 4567 ];
}