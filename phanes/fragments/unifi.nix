{ config, pkgs, lib, ... }:
let
  # use pinned pkgs for mongodb to avoid compiling it each time
  pinnedRepoName = "nixos-24.11-2024-12-15";
  pinnedPkgsRepo = pkgs.fetchgit {
    name = pinnedRepoName;
    leaveDotGit = true;
    url = "https://github.com/nixos/nixpkgs";
    rev = "314e12ba369ccdb9b352a4db26ff419f7c49fa84";
    hash = "sha256-5fNndbndxSx5d+C/D0p/VF32xDiJCJzyOqorOYW4JEo=";
  };
  pinnedPkgs = import pinnedPkgsRepo { config.allowUnfree = true; };
  httpPort = 8443;
in
{
  # prevent repo from being garbage collected
  environment.etc."${pinnedRepoName}".source = pinnedPkgsRepo;

  # enable to use desktop to build mongodb
  # (add "--max-jobs 0" to avoid building locally)
  # (also remember to move /tmp to disk to not run out of memory)
  # custom.remote-build-desktop.enable = true;

  nixpkgs.config.allowUnfree = true;
  services.unifi = {
    enable = true;
    openFirewall = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pinnedPkgs.pkgs.mongodb-7_0;
  };
  programs.ssh = {
    pubkeyAcceptedKeyTypes = [ "+ssh-rsa" ];
    hostKeyAlgorithms = [ "+ssh-rsa" ];
  };

  networking.firewall.allowedTCPPorts = [ httpPort ];

  environment.etc."unifi-mongodb.conf".text = ''
    setParameter:
      diagnosticDataCollectionEnabled: false
  '';

  services.nginxProxy.paths."unifi" = {
    serverHost = "trans-rights.withsam.org";
    proto = "https";
    port = httpPort;
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

  # systemd = {
  #   timers.unifi-rebooter = {
  #     wantedBy = [ "timers.target" ];
  #     partOf = [ "unifi-rebooter.service" ];
  #     timerConfig = {
  #       OnCalendar = "Mon *-*-* 03:00:00";
  #       Persistent = true;
  #     };
  #   };
  #   services.unifi-rebooter = {
  #     after = [ "network.target" ];
  #     serviceConfig = {
  #       Type = "oneshot";
  #       User = "sam";
  #       WorkingDirectory = "/home/sam";
  #     };

  #     script = ''
  #       ${pkgs.openssh}/bin/ssh admin@192.168.0.8 reboot
  #     '';
  #   };
  # };
}
