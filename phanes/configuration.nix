{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (import ../_autoload.nix ./.)
  ];

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.kernel.sysctl = lib.mkForce {
    "vm.swappiness" = 15;
    "vm.overcommit_memory" = 1;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  services.openssh.enable = true;

  networking = {
    hostId = "A5580085";
    hostName = "phanes";
    defaultGateway = "192.168.0.1";
    nameservers = [ "1.1.1.1" ];
    interfaces.net0.ipv4.addresses = [{
      address = "192.168.0.5";
      prefixLength = 24;
    }];
    dhcpcd.enable = false;
  };

  systemd.network.links."10-net0" = {
    matchConfig.PermanentMACAddress = "3c:18:a0:04:26:7e";
    linkConfig = {
      Name = "net0";
      WakeOnLan = "magic";
    };
  };

  time.timeZone = "Africa/Harare";

  system.stateVersion = "25.05";

  environment.systemPackages = with pkgs; [
    wol
  ];
}

