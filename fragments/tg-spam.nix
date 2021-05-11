{config, lib, pkgs, ...}:
{
  systemd.services.spamwastaken = {
    description = "@spamwastaken";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    path = [
      (pkgs.python37.withPackages (ps: with ps; [
        (ps.callPackage ../packages/telethon.nix {})
      ]))
    ];

    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/home/spamwastaken/botmachine";
      ExecStart = "/home/spamwastaken/botmachine/spam.py";
      Restart = "always";
      RestartSec = 5;
      User = "spamwastaken";
    };
  };

  users.extraUsers.spamwastaken = {
    description = "@spamwastaken";
    home = "/home/spamwastaken";
    createHome = true;
  };
}

