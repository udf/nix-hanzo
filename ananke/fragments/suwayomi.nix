{ config, lib, pkgs, ... }:
{
  virtualisation.oci-containers.containers.suwayomi = {
    image = "ghcr.io/suwayomi/tachidesk:v0.7.0-r1446";
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
      JDK_JAVA_OPTIONS = "-Xmx512m";
    };
    extraOptions = [
      "--hostname=${config.networking.hostName}"
      "--memory=768m"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 4567 ];
}