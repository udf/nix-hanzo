{ config, lib, pkgs, ... }:
let
  python-pkg = pkgs.python311.withPackages (ps: with ps; [
    telethon
  ]);
in
{
  systemd.services.yeetbot = {
    description = "Yeet Telegram Bot";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ python-pkg ];

    serviceConfig = {
      User = "yeetbot";
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      WorkingDirectory = "/home/yeetbot/adab2";
      ExecStart = "${python-pkg}/bin/python bot.py";
    };
  };

  users.extraUsers.yeetbot = {
    description = "I beat my yacht and i yeet my bot";
    home = "/home/yeetbot";
    isSystemUser = true;
    group = "yeetbot";
    openssh.authorizedKeys.keys = config.users.users.sam.openssh.authorizedKeys.keys;
  };
  users.groups.yeetbot = { };
}