{ config, lib, pkgs, ... }:

let
  hostName = "nextcloud.withsam.org";
  imaginaryKey = "weniswars";
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
    extraOptions = {
      enabledPreviewProviders = [
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\TXT"
        "OC\\Preview\\Imaginary"
      ];
      preview_imaginary_url = "http://127.0.0.1:9000";
      preview_imaginary_key = imaginaryKey;
    };
  };

  virtualisation.oci-containers.containers.aio-imaginary = {
    image = "nextcloud/aio-imaginary";
    ports = [
      "9000:9000"
    ];
    environment = {
      IMAGINARY_SECRET = imaginaryKey;
    };
  };

  services.nginx.virtualHosts."${hostName}" = {
    useACMEHost = "durga.withsam.org";
    forceSSL = true;
  };

  security.acme.certs = {
    "durga.withsam.org".extraDomainNames = [ "nextcloud.withsam.org" ];
  };
}
