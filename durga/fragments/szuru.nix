{ config, lib, pkgs, ... }:
let
  CONFIG_PATH = "/var/lib/szuru/config.yaml";
  DATA_PATH = "/var/lib/szuru/data";
  SQL_PATH = "/var/lib/szuru/sql";
  SRC_DIR = "/var/lib/szuru/src";
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
    uid = 8008;
  };
  users.groups.szuru = {
    gid = 8008;
  };

  systemd.services.szuru =
    let
      scriptText = ''
        echo 1>&2 "docker compose file: $ARION_PREBUILT"
        arion --prebuilt-file "$ARION_PREBUILT" up --build --abort-on-container-exit
      '';
    in
    {
      # force rebuild every service run
      script = lib.mkForce scriptText;
      # dump version into a env file so that the build can pick it up
      serviceConfig = {
        EnvironmentFile = "-/run/szuru.env";
        ExecStartPre = pkgs.writeShellScript "szuru-git-ver.sh" ''
          cd "${SRC_DIR}"
          VERSION=$(${pkgs.git}/bin/git describe --always --dirty --long --tags)
          echo BUILD_INFO=$VERSION > /run/szuru.env
        '';
        ExecReload = pkgs.writeShellScript "szuru-reload.sh" scriptText;
      };
    };

  # based on https://github.com/rr-/szurubooru/blob/master/docker-compose.yml
  virtualisation.arion.projects.szuru = {
    serviceName = "szuru";
    settings.services = {
      server = {
        out.service.build.args = {
          BUILD_INFO = "\${BUILD_INFO}";
          PUID = UID;
          PGID = GID;
        };
        service = {
          build.context = "${SRC_DIR}/server";
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
      };

      client = {
        out.service.build.args = {
          BUILD_INFO = "\${BUILD_INFO}";
        };
        service = {
          build.context = "${SRC_DIR}/client";
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
      };

      sql.service = {
        image = "postgres:16-alpine";
        command = [ "postgres" "-c" "jit=off" ];
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
