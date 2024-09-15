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
  boot.kernelPackages = pkgs.linuxPackages_hardened;
  boot.kernel.sysctl = lib.mkForce {
    "vm.swappiness" = 15;
    "vm.overcommit_memory" = 1;
  };

  networking.hostName = "durga";
  networking.enableIPv6 = false;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.dhcpcd.extraConfig = ''
    # ignore interfaces generated by docker
    denyinterfaces veth*
  '';

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  services.openssh.enable = true;
  custom.fail2endlessh.enable = true;
  custom.ipset-block = {
    enable = true;
  };

  time.timeZone = "UTC";
  system.stateVersion = "22.11";

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    operation = "boot";
    flags = [ "--upgrade-all" ];
    dates = "Fri *-*-* 20:00:00";
  };

  systemd.services.nixos-upgrade.serviceConfig = {
    ExecStartPost = "${config.systemd.package}/bin/shutdown -r +1";
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
