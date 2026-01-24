{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.pihole-container;
in
{
  options.services.pihole-container = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether or not to enable the pihole container";
    };
    serverIP = mkOption {
      type = types.str;
      default = "";
      description = "Server IP address, passed to pihole via the ServerIP environmental variable";
    };
    httpsPort = mkOption {
      type = types.port;
      default = 16443;
      description = "Port to expose the https server on";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open httpsPort to the outside network, DNS ports (53) are always allowed.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.serverIP != "";
        message = "services.pihole-container.serverIP must be set when services.pihole-container.enable is true";
      }
    ];

    virtualisation.oci-containers.containers.pihole = {
      # MARK: pinned version
      image = "pihole/pihole:2025.11.1";
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "${toString cfg.httpsPort}:443"
      ];
      volumes = [
        "/var/lib/pihole/:/etc/pihole/"
        "/var/lib/dnsmasq.d:/etc/dnsmasq.d/"
      ];
      environment = {
        ServerIP = cfg.serverIP;
        TZ = "Africa/Johannesburg";
        WEB_PORT = toString cfg.httpsPort;
      };
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--dns=1.1.1.1"
        "--no-healthcheck"
        "--hostname=${config.networking.hostName}"
      ];
    };

    systemd.services."${config.virtualisation.oci-containers.containers.pihole.serviceName}" = {
      serviceConfig = {
        MemorySwapMax = 0;
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ 53 ] ++ (optional cfg.openFirewall cfg.httpsPort);
      allowedUDPPorts = [ 53 ];
    };
  };
}
