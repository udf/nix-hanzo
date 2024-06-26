{ config, lib, pkgs, ... }:
let
  python-pkg = pkgs.python311.withPackages (ps: with ps; [
    (callPackage ../packages/telethon-old.nix { })
    aiohttp
    elasticsearch
    elastic-transport
    elasticsearch-dsl
    cachetools
    boltons
    regex
    (emoji.overrideAttrs
      (oldAttrs: rec {
        version = "1.7.0";
        src = pkgs.fetchFromGitHub {
          owner = "carpedm20";
          repo = "emoji";
          rev = "v${version}";
          sha256 = "sha256-vKQ51RP7uy57vP3dOnHZRSp/Wz+YDzeLUR8JnIELE/I=";
        };
      }))
  ]);
in
{
  imports = [
    ./elasticsearch.nix
  ];

  systemd.services.tagbot = {
    description = "@TheTagBot";
    after = [ "network.target" "elasticsearch.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ python-pkg ];

    serviceConfig = {
      User = "tagbot";
      Group = "tagbot";
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      WorkingDirectory = "/home/tagbot/tagbot/";
      ExecStart = "${python-pkg}/bin/python bot.py";
    };
  };

  users.extraUsers.tagbot = {
    description = "TagBot user";
    home = "/home/tagbot";
    isNormalUser = true;
    group = "tagbot";
  };
  users.groups.tagbot = { };
}
