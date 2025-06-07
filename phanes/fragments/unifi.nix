{ config, pkgs, lib, ... }:
let
  httpsPort = 8443;
  httpsCaptivePortalPort = 8843;
  httpCaptivePortalPort = 8880;
  containerIP = "192.168.0.4";
in
{
  systemd.services."container@unifi".after = [ "NetworkManager-wait-online.service" ];

  containers.unifi = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "${containerIP}/24";
    config = { config, pkgs, lib, ... }: {
      imports = [
        ../../_common/fragments/deterministic-ids.nix
      ];

      system.stateVersion = "25.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ httpsPort ];
        };
        defaultGateway = "192.168.0.1";
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

      nixpkgs.config.allowUnfree = true;
      services.unifi = {
        enable = true;
        openFirewall = true;
        unifiPackage = pkgs.unifi;
        mongodbPackage = pkgs.mongodb-ce;
      };

      environment.etc."unifi-mongodb.conf".text = ''
        setParameter:
          diagnosticDataCollectionEnabled: false
      '';
    };
  };

  # add rsa, for being able to ssh into unifi devices for manual management
  programs.ssh = {
    pubkeyAcceptedKeyTypes = [ "+ssh-rsa" ];
    hostKeyAlgorithms = [ "+ssh-rsa" ];
  };

  networking.firewall.allowedTCPPorts = [ httpsPort httpsCaptivePortalPort httpCaptivePortalPort ];

  services.nginxProxy.paths."unifi" = {
    serverHost = "trans-rights.withsam.org";
    extraServerConfig = ''
      listen ${toString httpsPort} ssl;
      listen ${toString httpsCaptivePortalPort} ssl;
      listen ${toString httpCaptivePortalPort};
    '';
    proto = "https";
    port = httpsPort;
    host = containerIP;
    useAuth = false;
    extraConfig = ''
      allow 192.168.0.0/16;
      deny all;

      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $http_connection;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Host $http_host;
    '';
  };
}
