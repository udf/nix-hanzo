{ config, lib, pkgs, ... }:
let
  PORT = 4567;
  UID = toString config.users.users.suwayomi.uid;
  GID = toString config.users.groups.suwayomi.gid;
in
{
  virtualisation.oci-containers.containers.suwayomi = {
    image = "ghcr.io/suwayomi/tachidesk:v1.0.0-r1531";
    ports = [
      "${toString PORT}:${toString PORT}"
    ];
    volumes = [
      "suwayomi:/home/suwayomi/.local/share/Tachidesk"
    ];
    environment = {
      TZ = "Africa/Johannesburg";
      EXTENSION_REPOS = ''[ "https://github.com/keiyoushi/extensions/tree/repo" ]'';
      BIND_PORT = toString PORT;
    };
    extraOptions = [
      "--hostname=${config.networking.hostName}"
      "--memory=2048m"
      "--user=${UID}:${GID}"
    ];
  };

  users.extraUsers.suwayomi = {
    home = "/home/suwayomi";
    isSystemUser = true;
    group = "suwayomi";
  };
  users.groups.suwayomi = { };

  services.nginxProxy.paths = {
    "suwayomi" = {
      port = PORT;
      authMessage = "*notices ur bulge* OwO, what's this?";
      secureLinks = true;
      secureLinkParam = "kawaii";
    };
  };
}
