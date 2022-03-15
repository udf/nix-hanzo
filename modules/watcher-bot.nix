{ config, lib, pkgs, ... }:
with lib;
let
  python-pkg = pkgs.python39.withPackages (ps: with ps; [
    (callPackage ../packages/watcher-bot.nix { })
  ]);
  cfg = config.services.watcher-bot;
in
{
  options.services.watcher-bot = {
    plugins = mkOption {
      type = types.listOf types.str;
      default = [ "systemd" ];
      description = "List of builtin plugins to load";
    };
  };

  config = {
    systemd.services.watcher-bot = {
      description = "Watchdog Telegram Bot";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ python-pkg ];
      environment = {
        PYTHONPATH = "${../constants/watcher}";
      };

      serviceConfig = {
        Type = "simple";
        User = "watcher";
        EnvironmentFile = /home/watcher/watcher.env;
        Restart = "always";
        RestartSec = 5;
        WorkingDirectory = "/home/watcher/";
        ExecStart = "${python-pkg}/bin/python -m watcher-bot ${concatStringsSep " " cfg.plugins}";
      };
    };

    users.extraUsers.watcher = {
      description = "Watchdog bot user";
      home = "/home/watcher";
      isSystemUser = true;
      createHome = true;
      group = "watcher";
      extraGroups = [ "systemd-journal" ];
    };
    users.groups.watcher = { };
  };
}
