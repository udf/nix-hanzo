{
  config,
  lib,
  pkgs,
  ...
}:

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
    package = pkgs.nextcloud32;
    hostName = hostName;
    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = "/var/lib/secrets/nextcloud-admin-pass";
    };
    settings = {
      overwriteprotocol = "https";
      enabledPreviewProviders = [
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\TXT"
        "OC\\Preview\\Movie"
        "OC\\Preview\\MP4"
        "OC\\Preview\\MKV"
        "OC\\Preview\\Imaginary"
      ];
      preview_imaginary_url = "http://127.0.0.1:9000";
      preview_imaginary_key = imaginaryKey;
    };
  };

  virtualisation.oci-containers.containers.aio-imaginary = {
    # MARK: pinned version
    image = "nextcloud/aio-imaginary:20260122_105751";
    ports = [
      "127.0.0.1:9000:9000"
    ];
    environment = {
      IMAGINARY_SECRET = imaginaryKey;
    };
  };

  systemd = {
    services.nextcloud-cron.path = [ pkgs.ffmpeg ];
    services.phpfpm-nextcloud.path = [ pkgs.ffmpeg ];
    services.docker-aio-imaginary.serviceConfig.TimeoutStopSec = lib.mkForce 10;

    timers.nextcloud-preview-gen = {
      wantedBy = [ "timers.target" ];
      after = [ "nextcloud-setup.service" ];
      partOf = [ "nextcloud-preview-gen.service" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "15m";
      };
    };

    services.nextcloud-preview-gen = {
      after = [ "nextcloud-setup.service" ];
      path = [ pkgs.ffmpeg ];
      serviceConfig = {
        User = "nextcloud";
        Type = "oneshot";
        WorkingDirectory = "/var/lib/nextcloud/config";
      };
      script = ''
        /run/current-system/sw/bin/nextcloud-occ preview:generate-all -vvv
      '';
    };
  };

  services.nginx.virtualHosts."${hostName}" = {
    useACMEHost = "durga.withsam.org";
    forceSSL = true;
  };

  security.acme.certs = {
    "durga.withsam.org".extraDomainNames = [ hostName ];
  };
}
