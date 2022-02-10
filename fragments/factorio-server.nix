{ config, lib, pkgs, ... }:
let
  tmux = "${pkgs.tmux}/bin/tmux";
  port = 34197;
  private = import ../constants/private.nix;
  master = import <nixpkgs-master> { config = { allowUnfree = true; }; };
  factorioPkg = master.factorio-headless.override {
    username = private.factorioUsername;
    token = private.factorioToken;
  };
  configFile = pkgs.writeText "factorio.conf" ''
    use-system-read-write-data-directories=true
    [path]
    read-data=${factorioPkg}/share/factorio/data
    write-data=/home/factorio/server/data
  '';
in
{
  systemd.services.factorio-server = {
    description = "Factorio server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "forking";
      WorkingDirectory = "/home/factorio/server";
      KillSignal = "SIGINT";
      ExecStart =
        let
          cmd = toString [
            "${factorioPkg}/bin/factorio"
            "--config=${configFile}"
            "--start-server=autism"
            "--port=${toString port}"
            "--mod-directory=mods"
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
    isNormalUser = true;
  };
}
