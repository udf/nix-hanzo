{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "syncthing";
    dataDir = "/home/syncthing";
    configDir = "/home/syncthing/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
  };

  environment.etc."syncthing/rescan.sh".source = pkgs.writeScript "rescan.sh" ''
    #!${pkgs.bash}/bin/bash
    # rescan.sh {syncthing api key} {syncthing folder id}
    ${lib.getExe pkgs.curl} -s -X POST -H "X-API-Key:$1" "http://localhost:8384/rest/db/scan?folder=$2"
  '';

  users.users.sam.extraGroups = [ "syncthing" ];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 204800;
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
}
