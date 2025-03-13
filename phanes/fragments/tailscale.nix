{ config, lib, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    port = 41641;
    useRoutingFeatures = "both";
  };

  environment.systemPackages = [ pkgs.tailscale ];

  custom.ipset-block.exceptPorts = [ config.services.tailscale.port ];

  networking = {
    networkmanager.dispatcherScripts = [
      {
        source = pkgs.writeText "up-udp-gro-forwarding" ''
          if [ "$2" != "up" ]; then
            logger "exit: event $2 != up"
            exit
          fi

          ${lib.getExe pkgs.ethtool} -K $DEVICE_IFACE rx-udp-gro-forwarding on rx-gro-list off
        '';
        type = "basic";
      }
    ];
    firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
