{ config, lib, pkgs, ... }:
let
  python-pkg = pkgs.python310.withPackages (ps: with ps; [
    (callPackage ../../_common/packages/telethon.nix { })
    (callPackage ../packages/bprint.nix { })
  ]);
in
{
  systemd.services.stringifybot = {
    description = "Stringify Telegram Bot";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ python-pkg ];

    serviceConfig = {
      User = "stringifybot";
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      WorkingDirectory = "/home/stringifybot/stringifybot";
      ExecStart = "${python-pkg}/bin/python bot.py";
    };
  };

  users.extraUsers.stringifybot = {
    description = "stringifybot user";
    home = "/home/stringifybot";
    isSystemUser = true;
    group = "stringifybot";
  };
  users.groups.stringifybot = { };
}
