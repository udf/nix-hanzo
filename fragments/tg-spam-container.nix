{ config, lib, pkgs, ... }:
{
  imports = [
    ../constants/vpn.nix
    ../modules/vpn-containers.nix
  ];

  services.vpnContainers.tg-spam = {
    ipPrefix = "192.168.3";
    bindMounts = {
      "/mnt/spamwastaken" = {
        hostPath = "/srv/spamwastaken";
      };
    };
    config = { config, pkgs, ... }: {
      imports = [
        ../modules/watcher-bot.nix
      ];

      systemd.services.spamwastaken = {
        description = "@spamwastaken";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        path = [
          (pkgs.python39.withPackages (ps: with ps; [
            (ps.callPackage ../packages/telethon.nix { })
          ]))
        ];

        serviceConfig = {
          Type = "simple";
          WorkingDirectory = "/mnt/spamwastaken/";
          ExecStart = "/mnt/spamwastaken/spam.py";
          Restart = "always";
          RestartSec = 5;
          User = "spamwastaken";
        };
      };

      users.extraUsers.spamwastaken = {
        description = "@spamwastaken";
        isNormalUser = true;
      };
    };
  };
}
