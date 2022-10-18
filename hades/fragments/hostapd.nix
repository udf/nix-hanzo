{ config, lib, pkgs, ... }:
let
  private = (import ../../_common/constants/private.nix).hades;
in
{
  systemd.services.ap-watcher = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      Restart = "always";
    };
    path = [
      pkgs.iputils
    ];

    script = ''
      sleep 60
      fails=0
      while true; do
        if ping -W 1 -c 1 192.168.0.8 >/dev/null ; then
          systemctl stop hostapd
          fails=0
        else
          fails="$((fails+1))"
        fi
        if (( fails == 5 )); then
          systemctl start hostapd
        fi
        sleep 1
      done
    '';
  };

  systemd.services.hostapd = {
    wantedBy = lib.mkForce [ ];
  };

  services.hostapd = {
    enable = true;
    interface = "wlan0";
    hwMode = "g";
    ssid = "Hades";
    wpaPassphrase = private.passphrase;
    noScan = true;
    channel = 7;
    extraConfig = ''
      ht_capab=[SHORT-GI-20][SHORT-GI-40][TX-STBC][DELAYED-BA][LSIG-TXOP-PROT]
    '';
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    servers = [
      "1.1.1.1"
    ];
    extraConfig = ''
      interface=wlan0
      listen-address=10.0.0.1
      dhcp-range=10.0.0.2,10.0.0.150,12h
      dhcp-option=6,10.0.0.1
    '';
  };

  networking.nat = {
    enable = true;
    externalInterface = "eth0";
    internalIPs = [
      "10.0.0.0/24"
    ];
  };

  networking.firewall.trustedInterfaces = [ "wlan0" ];
}
