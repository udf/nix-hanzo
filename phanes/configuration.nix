{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (import ../_autoload.nix ./.)
  ];

  services.zfs.trim.enable = true;

  powerManagement.cpuFreqGovernor = "ondemand";

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
    powerKey = "ignore";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.kernelParams = [ "preempt=full" ];
  boot.kernel.sysctl = lib.mkForce {
    "vm.swappiness" = 15;
    "vm.overcommit_memory" = 1;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  services.openssh.enable = true;

  users.users.sam.extraGroups = [ "networkmanager" ];
  networking = {
    hostId = "A5580085";
    hostName = "phanes";
    networkmanager = {
      enable = true;
    };
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
  };

  time.timeZone = "Africa/Harare";

  system.stateVersion = "25.05";

  environment.systemPackages = with pkgs; [
    wol
    intel-gpu-tools
  ];
}

