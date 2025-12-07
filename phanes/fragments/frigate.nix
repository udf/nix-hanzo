{ config, lib, pkgs, ... }:
{
  virtualisation.oci-containers.containers.frigate = {
    image = "ghcr.io/blakeblackshear/frigate:0.16.3";
    ports = [
      # "8971:8971" # Web UI
      "8971:5000" # Web UI (no auth)
      "8554:8554" # RTSP feeds
      # "8555:8555/tcp" # WebRTC over tcp
      # "8555:8555/udp" # WebRTC over udp
    ];
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/var/lib/frigate/config:/config"
      "/var/lib/frigate/media:/media/frigate"
      "/var/cache/frigate:/tmp/cache"
    ];
    labels = {
      # ignore tags starting with commit hashes
      "diun.exclude_tags" = "^[0-9a-f]{7}(-|$)";
      "diun.max_tags" = "100";
    };
    extraOptions = [
      "--cap-add=CAP_PERFMON"
      "--device=/dev/dri/renderD128"
      "--shm-size=256m"
    ];
  };

  systemd.services.podman-frigate.serviceConfig = {
    Nice = -20;
    CPUSchedulingPolicy = "fifo";
    CPUSchedulingPriority = 99;
    IOSchedulingClass = "realtime";
    IOSchedulingPriority = 0;
  };

  users.users.sam.extraGroups = [ "podman" ];

  networking.firewall = {
    allowedTCPPorts = [ 8971 ];
  };

  services.nginxProxy.paths = {
    "frigate" = {
      port = 8971;
      useAuthCookie = true;
      authMessage = "The eye is watching us.";
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;
      '';
    };
  };
}