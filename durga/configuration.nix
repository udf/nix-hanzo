{ config, lib, pkgs, options, ... }:
{
  imports = [
    ./hardware-configuration.nix
    (import ../_autoload.nix ./.)
  ];

  boot.cleanTmpDir = true;

  zramSwap.enable = true;
  boot.kernel.sysctl = {
    "vm.swappiness" = 0;
  };

  networking.hostName = "durga";
  networking.domain = "";

  services.openssh.enable = true;
  custom.fail2endlessh.enable = true;

  time.timeZone = "UTC";
  system.stateVersion = "22.11";

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
}
