{config, lib, pkgs, ...}:
with lib;
let
  python = pkgs.python37;
in
{
  options.services.spoilerobot = {
    enable = lib.mkEnableOption "Enable spoilerobot service";
  };

  config = lib.mkIf config.services.spoilerobot.enable {
    systemd.services.spoilerobot = {
      description = "Spoilerobot";
      after = ["network.target" "postgresql.service"];
      wantedBy = ["multi-user.target"];
      path = [
        (python.withPackages (ps: with ps; [
          cryptography psycopg2 python-telegram-bot
        ]))
      ];

      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "/home/spoilerobot";
        ExecStart = "/home/spoilerobot/start.sh";
        Restart = "always";
        RestartSec = 20;
        User = "spoilerobot";
      };
    };

    users.extraUsers.spoilerobot = {
      description = "Spoilerobot";
      home = "/home/spoilerobot";
      createHome = true;
      useDefaultShell = true;
    };
  };
}

