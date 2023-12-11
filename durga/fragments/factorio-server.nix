{ config, lib, pkgs, ... }:
let
  tmux = "${pkgs.tmux}/bin/tmux";
  port = 34197;
  private = import ../constants/private.nix;
  pkgs_x86 = import <nixpkgs-unstable> {
    config.allowUnfree = true;
    system = "x86_64-linux";
  };
  factorioPkg = pkgs_x86.factorio-headless.override {
    username = private.factorioUsername;
    token = private.factorioToken;
    versionsJson = ../constants/factorio-versions.json;
  };
  configFile = pkgs.writeText "factorio.conf" ''
    use-system-read-write-data-directories=true
    [path]
    read-data=${factorioPkg}/share/factorio/data
    write-data=/home/factorio/server/data
  '';
in
{
  # boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

  systemd.services.factorio-server = {
    description = "Factorio server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      LD_PRELOAD = "${pkgs.mimalloc}/lib/libmimalloc.so";
      MIMALLOC_PAGE_RESET = "0";
      HUGETLB_MORECORE = "thp";
      MIMALLOC_LARGE_OS_PAGES = "1";
    };

    serviceConfig = {
      Type = "forking";
      WorkingDirectory = "/home/factorio/server";
      KillSignal = "SIGINT";
      ExecStart =
        let
          cmd = toString [
            "${pkgs.box64}/bin/box64 ${factorioPkg}/bin/factorio"
            "--config=${configFile}"
            "--start-server-load-latest"
            "--port=${toString port}"
            "--server-settings=server-settings.json"
            "--server-adminlist=server-adminlist.json"
          ];
        in
        "${tmux} new-session -d -s fac '${cmd}'";
      ExecStop = "${tmux} kill-session -t fac";
      Restart = "on-failure";
      RestartSec = 10;
      User = "factorio";
    };
  };

  networking.firewall.allowedUDPPorts = [ port ];

  users.extraUsers.factorio = {
    description = "Factorio server user";
    home = "/home/factorio";
    openssh.authorizedKeys.keys = config.users.users.sam.openssh.authorizedKeys.keys;
    isNormalUser = true;
  };

  users.groups = {
    factorio.members = [ "factorio" ];
  };
}