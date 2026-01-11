{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.hath;
in
{
  options.services.hath = {
    enable = mkEnableOption "Enable Hentai@Home service";

    user = mkOption {
      type = types.str;
      default = "hath";
      description = ''
        User account under which H@H runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "hath";
      description = ''
        Group under which H@H runs.
      '';
    };

    homeDir = mkOption {
      type = types.path;
      default = "/home/hath";
      description = ''
        The home directory for the hath user
      '';
    };

    cacheDir = mkOption {
      type = types.str;
      default = "./cache";
      description = ''
        The cache directory for the service
      '';
    };

    dataDir = mkOption {
      type = types.str;
      default = "./data";
      description = ''
        The data directory for the service
      '';
    };

    downloadDir = mkOption {
      type = types.str;
      default = "./download";
      description = ''
        The download directory for the service
      '';
    };

    logDir = mkOption {
      type = types.str;
      default = "./log";
      description = ''
        The log directory for the service
      '';
    };

    tempDir = mkOption {
      type = types.str;
      default = "./tmp";
      description = ''
        The temp directory for the service
      '';
    };

    port = mkOption {
      type = types.port;
      default = 6969;
      description = ''
        The port that H@H should listen for web connections on
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Open port to the outside network.
      '';
    };

  };

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = mkIf (cfg.openFirewall) [ cfg.port ];

    users.extraUsers."${cfg.user}" = {
      description = "H@H user";
      home = cfg.homeDir;
      createHome = true;
      isSystemUser = true;
      group = cfg.group;
    };

    users.groups = mkIf (cfg.group == "hath") { hath = { }; };

    systemd = {
      services.hath = {
        description = "Hentai@Home service";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          Type = "simple";
          Restart = "always";
          WorkingDirectory = cfg.homeDir;
          ExecStart = ''
            ${pkgs.hentai-at-home}/bin/HentaiAtHome \
              --port=${toString cfg.port} \
              --cache-dir=${cfg.cacheDir} \
              --data-dir=${cfg.dataDir} \
              --download-dir=${cfg.downloadDir} \
              --log-dir=${cfg.logDir} \
              --temp-dir=${cfg.tempDir} \
              --disable_logging
          '';
        };
      };
    };
  };
}
