{ config, lib, pkgs, options, ... }:
{
  imports = [
    ./hardware-configuration.nix
    (import ../_autoload.nix ./.)
  ];

  boot.tmp.cleanOnBoot = true;

  zramSwap = {
    enable = true;
    memoryPercent = 33;
  };
  boot.kernel.sysctl = {
    "vm.swappiness" = 15;
  };

  networking.hostName = "durga";
  networking.domain = "";
  networking.enableIPv6 = false;

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
  ];

  networking.nat = {
    enable = true;
    externalInterface = "enp0s3";
  };
}
