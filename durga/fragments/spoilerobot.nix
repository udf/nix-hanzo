{ config, lib, pkgs, ... }:
let
  python-pkg = pkgs.python311.withPackages (ps: with ps; [
    (callPackage ../packages/telethon.nix {})
    (callPackage ../packages/construct.nix {})
    asyncpg
    cryptography
  ]);
in
{
  services.postgresql.enable = true;

  systemd.services.spoilerobot = {
    description = "@spoilerobot";
    after = [ "network.target" "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ python-pkg ];

    serviceConfig = {
      Type = "simple";
      User = "spoilerobot";
      EnvironmentFile = /home/spoilerobot/spoilerobot.env;
      WorkingDirectory = "/home/spoilerobot/spoilerobot";
      ExecStart = "${python-pkg}/bin/python spoilerobot.py";
      Restart = "always";
      RestartSec = 5;
    };
  };

  users.extraUsers.spoilerobot = {
    description = "spoilerobot user";
    home = "/home/spoilerobot";
    isNormalUser = true;
    openssh.authorizedKeys.keys = config.users.users.sam.openssh.authorizedKeys.keys;
  };
}
