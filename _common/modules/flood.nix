{ config, lib, pkgs, ... }:
with lib;
let
  unstable = import <nixpkgs-unstable> { config = { allowUnfree = true; }; };
  floodPkg = unstable.nodePackages.flood.override (oldAttrs: {
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@jesec/flood/-/flood-0.0.0-master.7aec1e2.tgz";
      sha512 = "sha512-Z0WG+2+PMHUATIjuEQmFa+KxsVLc+n0L2HLdlZ0wYroKrdPs9EN2MPcQmdXuTBxo4ozEzbAnjQmKmtDJAbHglw==";
    };
  });
  cfg = config.services.flood;
in
{
  options.services.flood = {
    enable = mkEnableOption "Enable Flood webUI service";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/flood";
      description = ''
        The directory where Flood will create files.
      '';
    };

    allowedPaths = mkOption {
      type = types.listOf (types.path);
      default = [ ];
      description = ''
        List of paths that Flood is allowed to access (remember to put your downloads directory here because jesec is retarded)
      '';
    };

    user = mkOption {
      type = types.str;
      default = "rtorrent";
      description = ''
        User account under which Flood runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "rtorrent";
      description = ''
        Group under which Flood runs.
      '';
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = ''
        The host that Flood should listen for web connections on
      '';
    };

    port = mkOption {
      type = types.port;
      default = 3000;
      description = ''
        The port that Flood should listen for web connections on
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open services.flood.port to the outside network.
      '';
    };

    qbURL = mkOption {
      type = types.str;
      default = "http://127.0.0.1:${webUIPort}";
      description = ''
        URL to qBittorrent Web API
      '';
    };

    qbUser = mkOption {
      type = types.str;
      default = "admin";
      description = ''
        Username of qBittorrent Web API
      '';
    };

    qbPass = mkOption {
      type = types.str;
      default = "adminadmin";
      description = ''
        Password of qBittorrent Web API
      '';
    };

    baseURI = mkOption {
      type = types.str;
      default = "/";
      description = ''
        URI prefix for all http requests
      '';
    };
  };

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = mkIf (cfg.openFirewall) [ cfg.port ];

    systemd = {
      services.flood = {
        description = "Flood web UI service";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.mediainfo ];
        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          Type = "simple";
          Restart = "on-failure";
          WorkingDirectory = cfg.dataDir;
          ExecStart = ''
            ${floodPkg}/lib/node_modules/flood/dist/index.js \
              --auth none \
              --host ${escapeShellArg cfg.host} \
              --port ${toString cfg.port} \
              --rundir ${escapeShellArg cfg.dataDir} \
              ${escapeShellArgs (lists.concatMap (x: ["--allowedpath" x]) cfg.allowedPaths)} \
              --qburl ${escapeShellArg cfg.qbURL} \
              --qbuser ${escapeShellArg cfg.qbUser} \
              --qbpass ${escapeShellArg cfg.qbPass} \
              --baseuri ${escapeShellArg cfg.baseURI}
          '';
        };
      };

      tmpfiles.rules = [ "d '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} -" ];
    };
  };
}
