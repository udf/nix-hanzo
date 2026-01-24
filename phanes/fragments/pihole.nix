{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.pihole-container = {
    enable = true;
    serverIP = "192.168.0.5";
    httpsPort = 16443;
    openFirewall = true;
  };

  virtualisation.oci-containers.containers.nebula-sync = {
    # MARK: pinned version
    image = "ghcr.io/lovelaze/nebula-sync:v0.11.1";
    environmentFiles = [ "/var/lib/secrets/pihole/nebula-sync.env" ];
    environment = {
      FULL_SYNC = "true";
      RUN_GRAVITY = "true";
      CRON = "14 * * * *";
      CLIENT_SKIP_TLS_VERIFICATION = "true";
    };
    extraOptions = [ "--no-healthcheck" ];
  };

  users.users.sam.extraGroups = [ "podman" ];
}
