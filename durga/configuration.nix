{ config, lib, pkgs, options, ... }:
{
  imports = [
    ./hardware-configuration.nix
    (import ../_autoload.nix ./.)
  ];

  boot.cleanTmpDir = true;
  zramSwap.enable = true;
  networking.hostName = "durga";
  networking.domain = "";
  services.openssh.enable = true;

  time.timeZone = "UTC";
  system.stateVersion = "22.11";

  environment.systemPackages = with pkgs; [
    ffmpeg
    atool
    unzip
  ];
}
