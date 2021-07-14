{ config, lib, pkgs, ... }:
let
  tmux = "${pkgs.tmux}/bin/tmux";
in
{
  systemd.services.mc-server = {
    description = "Minecraft server";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    path = [ pkgs.openjdk16 ];

    serviceConfig = {
      Type = "forking";
      WorkingDirectory = "/home/mc/Enigmatica6Server-0.5.4";
      ExecStart = "${tmux} new-session -d -s mc 'java -Xmx8G -jar forge-1.16.5-36.1.31.jar'";
      ExecStop = "${tmux} kill-session -t mc";
      Restart = "on-failure";
      RestartSec = 10;
      User = "mc";
    };
  };

  networking.firewall.allowedTCPPorts = [ 25565 ];

  users.extraUsers.mc = {
    description = "Minecraft server user";
    home = "/home/mc";
    isNormalUser = true;
  };
}