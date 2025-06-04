{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.pihole-container;
  tag = "2025.05.1";
  # nix run nixpkgs#nix-prefetch-docker -- --image-name pihole/pihole --image-tag {tag}
  baseImage = pkgs.dockerTools.pullImage {
    imageName = "pihole/pihole";
    imageDigest = "sha256:db38df3e050606bd014c801c2cbb0b13f263d3122d3d817a8cbcee807688af24";
    hash = "sha256-OGSAXpmwfUnIZgo3v6GDJtCo5QvewJ1ILCCBURcGQQc=";
    finalImageName = "pihole/pihole";
    finalImageTag = tag;
  };

  patchedStartShOverlay = pkgs.stdenv.mkDerivation {
    name = "patched-pihole-start-sh-overlay";
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/pi-hole/docker-pi-hole/refs/tags/${tag}/src/start.sh";
      sha256 = "sha256-/nRwZGjw5t9lgykv1ilcVQ7OIR/6d59SCCOXd0IhSMs=";
    };
    patches = [ ./pihole-start.sh_tail_retry.patch ];
    phases = [ "unpackPhase" "patchPhase" "installPhase" ];
    unpackPhase = ''
      cp $src start.sh
      chmod +x start.sh
    '';
    installPhase = ''
      mkdir -p $out/usr/bin/
      cp start.sh $out/usr/bin/
    '';
  };
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
      image = "patched-pihole:${tag}";
      pull = "never";
      imageFile = pkgs.dockerTools.buildImage {
        name = "patched-pihole";
        tag = tag;
        fromImage = baseImage;
        copyToRoot = [ patchedStartShOverlay ];
        config.Cmd = [ "start.sh" ];
      };
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
