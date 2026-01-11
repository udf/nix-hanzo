{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (import ../_autoload.nix ./.)
  ];

  services.zfs.trim.enable = true;

  powerManagement.cpuFreqGovernor = "ondemand";

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "ignore";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.kernelParams = [ "preempt=full" "usbcore.autosuspend=-1" "usbcore.quirks=17ef:7205:k,1f75:0621:bk" ];
  boot.kernel.sysctl = lib.mkForce {
    "vm.swappiness" = 15;
    "vm.overcommit_memory" = 1;
  };
  boot.extraModprobeConfig = ''
    options zfs zio_taskq_batch_pct=50
    options zfs zfs_arc_shrinker_limit=0
    options zfs zfs_arc_max=${toString (4 * 1024 * 1024 * 1024)}
  '';

  zramSwap = {
    enable = true;
    memoryPercent = 150;
  };

  services.openssh.enable = true;
  custom.ipset-block = {
    enable = true;
  };

  users.users.sam.extraGroups = [ "networkmanager" ];
  networking = {
    hostId = "A5580085";
    hostName = "phanes";
    networkmanager = {
      enable = true;
    };
  };

  time.timeZone = "Africa/Harare";

  system.stateVersion = "25.05";

  environment.systemPackages = with pkgs; [
    wol
    intel-gpu-tools
  ];
}

