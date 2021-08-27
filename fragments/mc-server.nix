{ config, lib, pkgs, ... }:
let
  tmux = "${pkgs.tmux}/bin/tmux";
  java = "${pkgs.openjdk11}/bin/java";
in
{
  systemd.services.mc-server = {
    description = "Minecraft server";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "forking";
      WorkingDirectory = "/home/mc/autismcraft/server";
      ExecStart = "${tmux} new-session -d -s mc '${java} -Xmx8G -XX:+UseG1GC -XX:ParallelGCThreads=4 -XX:MaxGCPauseMillis=50 -server -jar forge-1.16.5-36.2.0.jar'";
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