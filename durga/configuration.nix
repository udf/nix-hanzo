{ config, lib, pkgs, options, ... }:
{
  imports = [
    ./hardware-configuration.nix
    (import ../_autoload.nix ./.)
    ((import ./nix/sources.nix).arion + "/nixos-module.nix")
  ];

  boot.tmp.cleanOnBoot = true;

  zramSwap = {
    enable = true;
    memoryPercent = 33;
  };
  boot.kernel.sysctl = {
    "vm.swappiness" = 15;
    "vm.overcommit_memory" = 1;
  };

  networking.hostName = "durga";
  networking.enableIPv6 = false;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  # dhcpcd sucks, i dont want a search domain pls stop adding it
  environment.etc."resolv.conf" = with lib; with pkgs; {
    source = writeText "resolv.conf" ''
      ${concatStringsSep "\n" (map (ns: "nameserver ${ns}") config.networking.nameservers)}
      options edns0
    '';
  };

  services.openssh.enable = true;
  custom.fail2endlessh.enable = true;
  custom.ipset-block = {
    enable = true;
    exceptPorts = [
      2234 # soulseek
      7709 # torrents
    ];
  };

  time.timeZone = "UTC";
  system.stateVersion = "22.11";

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    flags = [ "--upgrade-all" ];
    dates = "Fri *-*-* 20:00:00";
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "65536";
    }
  ];

  environment.systemPackages = with pkgs; [
    ffmpeg
    atool
    unzip
    btrfs-progs
    compsize
    docker-client
    docker-compose
    arion
  ];

  virtualisation = {
    # container name dns resolution is absolutely busted on podman
    # so switch everything to docker
    docker = {
      enable = true;
      storageDriver = "btrfs";
    };
    arion.backend = "docker";
    oci-containers.backend = "docker";
  };

  networking.nat = {
    enable = true;
    externalInterface = "enp0s3";
  };
}
