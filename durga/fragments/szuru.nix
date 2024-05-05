{ config, lib, pkgs, ... }:
let
  CONFIG_PATH = "/var/lib/szuru/config.yaml";
  DATA_PATH = "/var/lib/szuru/data";
  SQL_PATH = "/var/lib/szuru/sql";
  UI_PORT = 8008;
  UID = toString config.users.users.szuru.uid;
  GID = toString config.users.groups.szuru.gid;
  USER = "${UID}:${GID}";
in
{
  users.extraUsers.szuru = {
    home = "/home/szuru";
    isSystemUser = true;
    group = "szuru";
  };
  users.groups.szuru = { };

  # based on https://github.com/rr-/szurubooru/blob/master/docker-compose.yml
  virtualisation.arion.projects.szuru = {
    serviceName = "szuru";
    settings.services = {
      server.service = {
        build.context = "/var/lib/szuru/src/server";
        user = USER;
        depends_on = [ "sql" ];
        env_file = [ "/var/lib/szuru/.env" ];
        environment = {
          THREADS = 4;
          POSTGRES_HOST = "sql";
        };
        volumes = [
          "${DATA_PATH}:/data"
          "${CONFIG_PATH}:/opt/app/config.yaml"
        ];
      };

      client.service = {
        build.context = "/var/lib/szuru/src/client";
        depends_on = [ "server" ];
        environment = {
          BACKEND_HOST = "server";
          BASE_URL = "/";
        };
        volumes = [
          "${DATA_PATH}:/data:ro"
        ];
        ports = [
          "127.0.0.1:8008:80"
        ];
      };

      sql.service = {
        image = "postgres:16-alpine";
        restart = "unless-stopped";
        env_file = [ "/var/lib/szuru/.env" ];
        volumes = [
          "${SQL_PATH}:/var/lib/postgresql/data"
        ];
      };
    };
  };

  services.nginxProxy.paths = {
    "booru" = {
      port = UI_PORT;
      useAuth = false;
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Scheme $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Script-Name /szuru;
      '';
      extraServerConfig = ''
        client_max_body_size 25M;
      '';
    };
  };
}
