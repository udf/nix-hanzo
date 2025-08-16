{ config, lib, pkgs, ... }:
let
  unstable = import <nixpkgs-unstable> { config = { allowUnfree = true; }; };
  serviceOpts = {
    serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = lib.mkForce 5;
      RestartMode = lib.mkForce "direct";
    };
    unitConfig.RequiresMountsFor = "/backup/qbit";
  };
in
{
  services.qbittorrent = {
    enable = true;
    profileDir = "/var/lib/qbittorrent/.config";
    webuiPort = 8081;
    openFirewall = true;
    package = unstable.qbittorrent-nox;
  };

  services.flood = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
    port = 3000;
  };

  environment.etc."qbit/on_done.sh".source = pkgs.writeScript "on_done.sh" ''
    #!${pkgs.bash}/bin/bash
    # on_done.sh "%N" "%F" "/path/to/dest/" {syncthing api key} {syncthing folder id}
    echo "<4>Download completed: $1"
    cp -al "$2" "$3"
    ${lib.getExe pkgs.curl} -s -X POST -H "X-API-Key:$4" "http://localhost:8384/rest/db/scan?folder=$5"
  '';

  networking.firewall = {
    allowedTCPPorts = [ 32431 ];
    allowedUDPPorts = [ 32431 ];
  };

  custom.ipset-block.exceptPorts = [ 32431 ];

  users.users.sam.extraGroups = [ "qbittorrent" ];

  systemd.services.qbittorrent = lib.mkMerge [
    serviceOpts
    {
      serviceConfig = {
        LimitNOFILE = 65536;
        IOSchedulingClass = "idle";
        IOSchedulingPriority = 7;
        MemoryAccounting = "true";
        MemoryHigh = "4G";
        MemoryMax = "4G";
        MemorySwapMax = "2G";
      };
    }
  ];
  systemd.services.flood = serviceOpts;
}
