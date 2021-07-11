{ config, pkgs, ... }:
{
  systemd.services.hvotebot = {
    description = "Image vote bot for @JapaneseSpirit";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    path = [
      pkgs.bash
      (pkgs.python38.withPackages (ps: [
        (ps.callPackage ../packages/telethon.nix {})
        ps.cbor2
      ]))
    ];

    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/home/hvotebot/image-vote-bot";
      ExecStart = "/home/hvotebot/image-vote-bot/run.sh";
      Restart = "always";
      RestartSec = 5;
      User = "hvotebot";
    };
  };

  users.extraUsers.hvotebot = {
    description = "Image vote bot for @JapaneseSpirit";
    home = "/home/hvotebot";
    createHome = true;
  };
}