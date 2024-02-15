{ config, lib, pkgs, ... }:

let
  hostName = "nextcloud.withsam.org";
in
{
  services.nextcloud = {
    enable = true;
    database.createLocally = true;
    configureRedis = true;
    maxUploadSize = "16G";
    package = pkgs.nextcloud28;
    hostName = hostName;
    config = {
      overwriteProtocol = "https";
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = "/var/lib/secrets/nextcloud-admin-pass";
    };
    extraOptions.enabledPreviewProviders = [
      "OC\\Preview\\BMP"
      "OC\\Preview\\GIF"
      "OC\\Preview\\HEIC"
      "OC\\Preview\\JPEG"
      "OC\\Preview\\Krita"
      "OC\\Preview\\MarkDown"
      "OC\\Preview\\Movie"
      "OC\\Preview\\MP3"
      "OC\\Preview\\MP4"
      "OC\\Preview\\OpenDocument"
      "OC\\Preview\\PDF"
      "OC\\Preview\\PNG"
      "OC\\Preview\\TXT"
      "OC\\Preview\\XBitmap"
    ];
  };

  services.nginx.virtualHosts."${hostName}" = {
    useACMEHost = "durga.withsam.org";
    forceSSL = true;
  };

  security.acme.certs = {
    "durga.withsam.org".extraDomainNames = [ "nextcloud.withsam.org" ];
  };
}
