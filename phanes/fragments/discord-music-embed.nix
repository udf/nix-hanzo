{ config, lib, pkgs, ... }:
let
  pythonPkg = pkgs.python312.withPackages (ps: with ps; [
    aiohttp
    yarl
    pillow
    mutagen
  ]);
  port = 36900;
  coverCacheDir = "/var/cache/discord-music-embed/covers/";
  serverHost = (import ../../_common/constants/private.nix).homeHostname;
in
{
  systemd.services.discord-music-embed = {
    description = "music embed generator for discord";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pythonPkg ];
    environment = {
      PORT = toString port;
      SITE_NAME = "Sam says trans rights!";
      PAGE_TITLE = "Gaia embed";
      HTTP_HOST = "";
      MUSIC_DIR = "/backup/music/music";
      COVER_DIR = coverCacheDir;
      # SERVE_FILES = "1";
    };
    unitConfig = {
      RequiresMountsFor = "/backup/music";
    };

    serviceConfig = {
      User = "discord-music-embed";
      Type = "simple";
      Restart = "always";
      RestartMode = "direct";
      RestartSec = 5;
      WorkingDirectory = "/home/discord-music-embed/discord-music-embed";
      ExecStart = "${pythonPkg}/bin/python server.py";
      PrivateTmp = "true";
    };
  };

  services.nginx = {
    commonHttpConfig = ''
      map $http_x_forwarded_host $proxy_remote_host {
        "" $host;
        default $http_x_forwarded_host;
      }
    '';

    virtualHosts = {
      "music.${serverHost}" = {
        locations = {
          "~ [^/]$".extraConfig = ''
            error_page 420 = @embed;
            if ($args ~ "(?:^|&)embed(?:[=&]|$)") {
              return 420;
            }
            try_files _ @default;
          '';
          "^~ /cover/".extraConfig = ''
            alias ${coverCacheDir};
            try_files $uri @default;
          '';
          "@embed".extraConfig = ''
            proxy_pass http://localhost:${toString port};
            proxy_set_header X-Forwarded-Host $proxy_remote_host;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
      };
    };
  };

  users.extraUsers.discord-music-embed = {
    description = "discord-music-embed user";
    home = "/home/discord-music-embed";
    isSystemUser = true;
    group = "discord-music-embed";
    createHome = true;
  };
  users.groups.discord-music-embed = { };
}
