{ config, lib, pkgs, ... }:
let
  tmux = "${pkgs.tmux}/bin/tmux";
  java = "${pkgs.openjdk16}/bin/java";
  papermc = (pkgs.callPackage ../packages/papermc.nix {});
  papermcJar = "${papermc}/share/papermc/papermc.jar";
in
{
  systemd.services.mc-server = {
    description = "Minecraft server";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "forking";
      WorkingDirectory = "/home/mc/papermc";
      ExecStart = "${tmux} new-session -d -s mc '${java} -Xmx8G -jar ${papermcJar}'";
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