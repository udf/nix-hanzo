{ config, lib, pkgs, ... }:
{
  virtualisation.oci-containers.containers.frigate = {
    image = "ghcr.io/blakeblackshear/frigate:0.14.1";
    ports = [
      # "8971:8971" # Web UI
      "8971:5000" # Web UI (no auth)
      "8554:8554" # RTSP feeds
      "8555:8555/tcp" # WebRTC over tcp
      "8555:8555/udp" # WebRTC over udp
    ];
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/var/lib/frigate/config:/config"
      "/sync/frigate:/media/frigate"
      "/sync/frigate/cache:/tmp/cache"
    ];
    environment = {
    };
    extraOptions = [
      "--cap-add=CAP_PERFMON"
      "--device=/dev/dri/renderD128"
    ];
  };

  systemd.services.podman-frigate.serviceConfig.Nice = -9;

  users.users.sam.extraGroups = [ "podman" ];

  networking.firewall = {
    allowedTCPPorts = [ 8971 5000 9 ];
    allowedUDPPorts = [ 9 ];
  };
}