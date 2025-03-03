{ config, lib, pkgs, ... }:
with lib;
let
  unstable = import <nixpkgs-unstable> { config = { allowUnfree = true; }; };
  cfg = config.services.qbittorrent;
  configDir = "${cfg.dataDir}/.config";
  qbitPkg = unstable.qbittorrent-nox;
in
{
  options.services.qbittorrent = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Run qBittorrent headlessly as systemwide daemon
      '';
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent";
      description = ''
        The directory where qBittorrent will create files.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        User account under which qBittorrent runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        Group under which qBittorrent runs.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = ''
        qBittorrent web UI port.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open services.qBittorrent.port to the outside network.
      '';
    };

    openFilesLimit = mkOption {
      default = 65536;
      description = ''
        Number of files to allow qBittorrent to open.
      '';
    };

    maxMemory = mkOption {
      type = types.str;
      default = "";
      description = ''
        Maximum amount of memory to use (set via systemd's unit MemoryHigh/MemoryMax options)
      '';
    };
  };

  config = mkIf cfg.enable {

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    systemd.services.qbittorrent = {
      after = [ "network.target" ];
      description = "qBittorrent Daemon";
      wantedBy = [ "multi-user.target" ];
      path = [ qbitPkg ];
      serviceConfig = {
        ExecStart = ''
          ${qbitPkg}/bin/qbittorrent-nox \
            --profile=${configDir} \
            --webui-port=${toString cfg.port}
        '';
        Restart = "on-success";
        User = cfg.user;
        Group = cfg.group;
        LimitNOFILE = cfg.openFilesLimit;
        IOSchedulingClass = "idle";
        IOSchedulingPriority = 7;
      } // mkIf (cfg.maxMemory != "") {
        MemoryAccounting = "true";
        MemoryHigh = cfg.maxMemory;
        MemoryMax = cfg.maxMemory;
        MemorySwapMax = "0";
        MemoryZSwapMax = "0";
      };
    };

    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
        description = "qBittorrent Daemon user";
        isSystemUser = true;
      };
    };

    users.groups =
      mkIf (cfg.group == "qbittorrent") { qbittorrent = { }; };
  };
}
