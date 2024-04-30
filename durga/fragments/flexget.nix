{ config, lib, pkgs, ... }:

let
  port = 3539;
  flexgetPkg = pkgs.flexget.overrideAttrs (oldAttrs: {
    srcs = [
      oldAttrs.src
      (pkgs.fetchzip {
        url = "https://github.com/Flexget/webui/releases/download/2.0.29/dist.zip";
        hash = "sha256:1330czk6y9z5iqfph3rsazfs102bwn9mg2jjxd7h0jyvc7y9cbgf";
        name = "webui";
      })
    ];
    sourceRoot = ".";
    postUnpack = ''
      mv webui source/flexget/ui/v2/dist
      export sourceRoot=source
    '';
  });
in
{
  services.flexget = {
    enable = true;
    package = flexgetPkg;
    user = "flexget";
    homeDir = "/home/flexget";
    systemScheduler = false;
    config = ''
    tasks:
      nyaa-subsplease:
        rss: https://nyaa.si/?page=rss&q=subsplease+1080p&c=0_0&f=0
        regexp:
          accept:
            - placeholderdoesnotmatch
        download: /sync/downloads/flexget
    schedules:
      - tasks: 'nyaa-*'
        interval:
          minutes: 5
    web_server:
      bind: 127.0.0.1
      port: ${toString port}
      web_ui: yes
    '';
  };

  systemd.services.flexget.serviceConfig = {
    # remove install command that replaces the config file,
    # so that changes made in the webui are not reverted on every service run.
    ExecStartPre = lib.mkForce "";
  };

  users.extraUsers.flexget = {
    home = "/home/flexget";
    createHome = true;
    isSystemUser = true;
    group = "syncthing";
  };

  services.nginxProxy.paths = {
    "flexget" = {
      port = port;
      authMessage = "TO SHOW YOU THE POWER OF FLEXGET, I SAWED THIS WEBSITE IN HALF!";
    };
  };
}
