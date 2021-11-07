{ config, lib, pkgs, ... }:
let
  unstable = import <nixpkgs-unstable> {};
  python-pkg = unstable.python39.withPackages (ps: with ps; [
    (callPackage ../packages/telethon.nix {})
    aiohttp elasticsearch elasticsearch-dsl
    cachetools boltons regex emoji
  ]);
in
{
  imports = [
    ./elasticsearch.nix
  ];

  users.groups.tagbot = {
    members = ["syncthing"];
  };

  systemd.services.tagbot = {
    description = "@TheTagBot";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    path = [python-pkg];

    serviceConfig = {
      User = "tagbot";
      Group = "tagbot";
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      WorkingDirectory = "/srv/tagbot/";
      ExecStart = "${python-pkg}/bin/python bot.py";
    };
  };

  users.extraUsers.tagbot = {
    description = "TagBot user";
    home = "/home/tagbot";
    isNormalUser = true;
    extraGroups = ["tagbot"];
  };
}